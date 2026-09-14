import CocoaHeadsCore
import Foundation

/// Create one instance for the application and inject it into every window.
/// The operation gate serializes complete refresh/assertion round trips, not just actor turns.
public actor AccountClient {
  private struct Session: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let appleUserID: String
    var user: UserDTO
    var refreshPending = false
  }

  public nonisolated let isMock: Bool
  public nonisolated let configurationReady: Bool
  /// Lets the UI explain missing server configuration before Apple's authorization sheet.
  public nonisolated let availabilityError: AccountError?

  private let vault: any AccountCredentialVault
  private let storageKey: String
  private let backend: AccountBackend
  private let now: @Sendable () -> Date
  private let gate = AccountOperationGate()
  private var session: Session?
  private var loadedVault = false

  public init(
    configuration: EventClientConfiguration,
    apiKey: String,
    transport: any EventHTTPTransport = URLSessionEventTransport(),
    vault: any AccountCredentialVault = KeychainAccountVault(),
    attestation: any AccountAttestation = DeviceAccountAttestation(),
    now: @escaping @Sendable () -> Date = { .now }
  ) {
    isMock = configuration.environment == .mock
    let ready = AccountBackend.isConfigured(configuration, apiKey: apiKey)
    configurationReady = ready
    availabilityError = ready ? nil : .notConfigured
    self.vault = vault
    self.now = now
    let namespace = AccountBackend.namespace(configuration)
    storageKey = namespace + "/session"
    backend = AccountBackend(
      configuration: configuration, apiKey: apiKey,
      transport: transport, vault: vault, attestation: attestation, namespace: namespace)
  }

  public func signIn(request: AppleSignInRequest, appleUserID: String) async throws -> UserDTO {
    try await gate.run { try await self.signInLocked(request: request, appleUserID: appleUserID) }
  }

  /// A missing session is a normal signed-out state; temporary network failures still throw.
  public func restore() async throws -> UserDTO? {
    try await gate.run { try await self.restoreLocked() }
  }

  /// Fetches fresh account/role information. Expiring credentials rotate once across all callers.
  public func currentUser() async throws -> UserDTO {
    try await gate.run { try await self.currentUserLocked() }
  }

  /// Local credentials are cleared even if server-side revocation cannot be confirmed.
  public func signOut() async throws {
    try await gate.run { try await self.signOutLocked() }
  }

  /// Clears local credentials and the revoked device key only after server deletion succeeds.
  public func deleteAccount() async throws {
    try await gate.run { try await self.deleteAccountLocked() }
  }

  /// Used by AuthenticationServices credential-revocation handling without network access.
  public func clearLocalSession() async throws {
    try await gate.run { try await self.clearSessionLocked() }
  }

  /// Apple's opaque identifier, distinct from the backend UserDTO UUID.
  public func appleUserID() async -> String? {
    try? await gate.run { try await self.storedSession()?.appleUserID }
  }

  /// Sends ordinary API DTO bytes, without screen caching or implicit replay of mutations.
  public func authenticatedRequest(path: [String], method: String, body: Data? = nil) async throws -> Data {
    try await gate.run {
      try await self.authenticatedRequestLocked(path: path, method: method, body: body)
    }
  }

  #if DEBUG
    /// Available only for an explicitly selected mock environment; never invokes Apple or HTTP.
    public func signInMock(role: UserRole = .organizer) async throws -> UserDTO {
      try await gate.run { try await self.signInMockLocked(role: role) }
    }
  #endif

  private func signInLocked(request: AppleSignInRequest, appleUserID: String) async throws -> UserDTO {
    guard !isMock else { throw AccountError.mockSignInRequired }
    guard !request.identityToken.isEmpty, !request.authorizationCode.isEmpty, !appleUserID.isEmpty else {
      throw AccountError.invalidRequest
    }
    let data = try await backend.send(
      path: ["auth", "apple"], method: "POST", body: JSONEncoder().encode(request))
    let token = try decodeTokens(data)
    let value = makeSession(token, appleUserID: appleUserID)
    // Do not discard a successful token exchange just because its presenting view was dismissed.
    try save(value)
    return value.user
  }

  private func restoreLocked() async throws -> UserDTO? {
    guard try storedSession() != nil else { return nil }
    do {
      return try await currentUserLocked()
    } catch AccountError.authenticationRequired {
      return nil
    }
  }

  private func currentUserLocked() async throws -> UserDTO {
    let value = try await validSession()
    if isMock { return value.user }
    let data: Data
    do {
      data = try await backend.send(path: ["me"], method: "GET", bearer: value.accessToken)
    } catch let error as AccountError where error.statusCode == 401 {
      try clearSessionLocked()
      throw AccountError.authenticationRequired
    }
    guard let user = try? JSONDecoder().decode(UserDTO.self, from: data), user.id == value.user.id else {
      throw AccountError.invalidResponse
    }
    var updated = value
    updated.user = user
    try save(updated)
    return user
  }

  private func authenticatedRequestLocked(path: [String], method: String, body: Data?) async throws -> Data {
    let value = try await validSession()
    guard !isMock else { throw AccountError.mockEndpointUnavailable }
    do {
      return try await backend.send(path: path, method: method, body: body, bearer: value.accessToken)
    } catch let error as AccountError where error.statusCode == 401 {
      try clearSessionLocked()
      throw AccountError.authenticationRequired
    }
  }

  private func validSession() async throws -> Session {
    guard let value = try storedSession() else { throw AccountError.authenticationRequired }
    if value.refreshPending { throw AccountError.refreshUncertain }
    if isMock || value.expiresAt > now().addingTimeInterval(30) { return value }
    // Every caller enters through the same gate. Once this rotation completes, waiting
    // callers observe the replacement session instead of rotating the consumed token.
    return try await refresh(value)
  }

  private func refresh(_ previous: Session) async throws -> Session {
    do {
      let data = try await backend.send(
        path: ["auth", "refresh"], method: "POST",
        body: JSONEncoder().encode(RefreshRequest(refreshToken: previous.refreshToken)),
        beforeSend: { try await self.markRefreshPending() })
      let token = try decodeTokens(data)
      guard token.user.id == previous.user.id else { throw AccountError.invalidResponse }
      let value = makeSession(token, appleUserID: previous.appleUserID)
      try save(value)
      return value
    } catch AccountError.httpStatus(401, _) {
      try clearSessionLocked()
      throw AccountError.authenticationRequired
    } catch {
      // Once the refresh reached the transport, even timeout/cancellation may mean the
      // server rotated it. Persisting this state prevents replay after an app restart.
      if session?.refreshPending == true { throw AccountError.refreshUncertain }
      throw error
    }
  }

  private func markRefreshPending() throws {
    guard var value = session else { throw AccountError.authenticationRequired }
    value.refreshPending = true
    try save(value)
  }

  private func signOutLocked() async throws {
    do {
      if try storedSession() != nil, !isMock {
        let value = try await validSession()
        _ = try await backend.send(
          path: ["auth", "logout"], method: "POST",
          body: JSONEncoder().encode(RefreshRequest(refreshToken: value.refreshToken)),
          bearer: value.accessToken)
      }
    } catch {
      try clearSessionLocked()
      throw error
    }
    try clearSessionLocked()
  }

  private func deleteAccountLocked() async throws {
    let value = try await validSession()
    if !isMock {
      _ = try await backend.send(path: ["me"], method: "DELETE", bearer: value.accessToken)
    }
    try clearSessionLocked()
    if !isMock { try await backend.clearAttestation() }
  }

  private func storedSession() throws -> Session? {
    guard !loadedVault else { return session }
    if !isMock, let data = try vault.read(key: storageKey) {
      guard let value = try? JSONDecoder().decode(Session.self, from: data) else {
        throw AccountError.secureStorage
      }
      session = value
    }
    loadedVault = true
    return session
  }

  private func save(_ value: Session) throws {
    if !isMock { try vault.write(JSONEncoder().encode(value), key: storageKey) }
    session = value
    loadedVault = true
  }

  private func clearSessionLocked() throws {
    session = nil
    loadedVault = true
    if !isMock { try vault.remove(key: storageKey) }
  }

  private func decodeTokens(_ data: Data) throws -> TokenResponse {
    guard let tokens = try? JSONDecoder().decode(TokenResponse.self, from: data),
      !tokens.accessToken.isEmpty, !tokens.refreshToken.isEmpty, tokens.expiresIn > 0
    else { throw AccountError.invalidResponse }
    return tokens
  }

  private func makeSession(_ token: TokenResponse, appleUserID: String) -> Session {
    Session(
      accessToken: token.accessToken, refreshToken: token.refreshToken,
      expiresAt: now().addingTimeInterval(TimeInterval(token.expiresIn)),
      appleUserID: appleUserID, user: token.user)
  }

  #if DEBUG
    private func signInMockLocked(role: UserRole) throws -> UserDTO {
      guard isMock else { throw AccountError.invalidRequest }
      let user = UserDTO(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
        fullName: "Conta de demonstração", role: role)
      try save(
        Session(
          accessToken: "mock-access", refreshToken: "mock-refresh", expiresAt: .distantFuture,
          appleUserID: "mock-apple-user", user: user))
      return user
    }
  #endif
}
