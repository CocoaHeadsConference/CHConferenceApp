import CocoaHeadsCore
import CryptoKit
import Foundation
import Synchronization
import Testing

@testable import CocoaHeadsNetworking

@Suite("Account sessions and authenticated requests")
struct AccountClientTests {
  @Test("Mock account operations never access HTTP, Apple, or persistent credentials")
  func mockIsolation() async throws {
    let transport = AccountTestTransport([])
    let vault = AccountTestVault()
    let device = AccountTestAttestation(isSupported: false)
    let client = AccountClient(
      configuration: .init(environment: .mock), apiKey: "",
      transport: transport, vault: vault, attestation: device)
    #expect(client.isMock && client.configurationReady)
    #expect(client.availabilityError == nil)
    #expect(try await client.restore() == nil)
    let user = try await client.signInMock(role: .organizer)
    #expect(user.role == .organizer)
    #expect(try await client.currentUser() == user)
    #expect(await client.appleUserID() == "mock-apple-user")
    await #expect(throws: AccountError.mockEndpointUnavailable) {
      try await client.authenticatedRequest(path: ["organizer", "events"], method: "POST")
    }
    try await client.deleteAccount()
    #expect(try await client.restore() == nil)
    #expect(await transport.requests.isEmpty)
    #expect(await device.generatedKeys == 0)
    #expect(vault.accesses == 0)
  }

  @Test("Apple exchange persists a session and restores current user through the same server")
  func signInAndRestore() async throws {
    let user = accountTestUser()
    let transport = AccountTestTransport([try tokenResponse(), try response(user)])
    let vault = AccountTestVault()
    let client = try localClient(transport: transport, vault: vault)
    #expect(client.availabilityError == nil)
    #expect(try await client.signIn(request: appleRequest(), appleUserID: "apple-sub") == user)
    let reopened = try localClient(transport: transport, vault: vault)
    #expect(try await reopened.restore() == user)
    #expect(await reopened.appleUserID() == "apple-sub")
    let requests = await transport.requests
    #expect(requests.map { $0.url?.path } == ["/auth/apple", "/me"])
    #expect(requests[0].httpMethod == "POST")
    #expect(requests[0].value(forHTTPHeaderField: "X-API-Key") == "test-key")
    #expect(requests[0].value(forHTTPHeaderField: "Content-Type") == "application/json")
    #expect(requests[1].value(forHTTPHeaderField: "Authorization") == "Bearer access-1")
    #expect(requests.allSatisfy { $0.value(forHTTPHeaderField: "X-Attest-Assertion") == nil })
    let posted = try JSONDecoder().decode(AppleSignInRequest.self, from: #require(requests[0].httpBody))
    #expect(posted.nonce == "raw-nonce")
  }

  @Test("Concurrent account reads rotate an expiring token only once")
  func singleFlightRefresh() async throws {
    let user = accountTestUser()
    let transport = AccountTestTransport(
      [
        try tokenResponse(expiresIn: 1), try tokenResponse(suffix: "2"),
        try response(user), try response(user), try response(user)
      ], delay: .milliseconds(10))
    let client = try localClient(transport: transport)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    async let first = client.currentUser()
    async let second = client.currentUser()
    async let third = client.currentUser()
    let users = try await [first, second, third]
    #expect(users.allSatisfy { $0 == user })
    let requests = await transport.requests
    let refreshes = requests.filter { $0.url?.path == "/auth/refresh" }
    #expect(refreshes.count == 1)
    let body = try JSONDecoder().decode(RefreshRequest.self, from: #require(refreshes.first?.httpBody))
    #expect(body.refreshToken == "refresh-1")
    #expect(
      requests.filter { $0.url?.path == "/me" }.allSatisfy {
        $0.value(forHTTPHeaderField: "Authorization") == "Bearer access-2"
      })
    #expect(await transport.maximumConcurrent == 1)
  }

  @Test("An ambiguous rotation cannot replay its refresh token, including after restart")
  func uncertainRotationDoesNotReplay() async throws {
    let transport = AccountTestTransport([try tokenResponse(expiresIn: 1), .failure(.timedOut)])
    let vault = AccountTestVault()
    let client = try localClient(transport: transport, vault: vault)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    await #expect(throws: AccountError.refreshUncertain) { try await client.currentUser() }
    await #expect(throws: AccountError.refreshUncertain) { try await client.currentUser() }
    let reopened = try localClient(transport: transport, vault: vault)
    await #expect(throws: AccountError.refreshUncertain) { try await reopened.restore() }
    #expect(await transport.requests.count == 2)
    try await reopened.clearLocalSession()
    #expect(try await reopened.restore() == nil)
  }

  @Test("Rejected refresh clears the session instead of leaving stale organizer access")
  func rejectedRotation() async throws {
    let transport = AccountTestTransport([
      try tokenResponse(expiresIn: 1), .response(.init(data: Data(), statusCode: 401))
    ])
    let vault = AccountTestVault()
    let client = try localClient(transport: transport, vault: vault)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    #expect(try await client.restore() == nil)
    #expect(await client.appleUserID() == nil)
    #expect(try await localClient(transport: transport, vault: vault).restore() == nil)
    #expect(await transport.requests.count == 2)
  }

  @Test("Offline current-user lookup preserves valid credentials and a later retry succeeds")
  func offlineSessionSurvives() async throws {
    let transport = AccountTestTransport([
      try tokenResponse(), .failure(.notConnectedToInternet), try response(accountTestUser())
    ])
    let vault = AccountTestVault()
    let client = try localClient(transport: transport, vault: vault)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    await #expect(throws: URLError.self) { try await client.restore() }
    #expect(try await client.restore() == accountTestUser())
    #expect(await transport.requests.filter { $0.url?.path == "/auth/refresh" }.isEmpty)
  }

  @Test("Logout clears local credentials even if server revocation fails")
  func failedLogoutStillClearsLocalCredentials() async throws {
    let transport = AccountTestTransport([try tokenResponse(), .response(.init(data: Data(), statusCode: 503))])
    let vault = AccountTestVault()
    let client = try localClient(transport: transport, vault: vault)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    await #expect(throws: AccountError.httpStatus(503)) { try await client.signOut() }
    #expect(try await client.restore() == nil)
    #expect(try await localClient(transport: transport, vault: vault).restore() == nil)
  }

  @Test("Account deletion keeps the session on failure and removes it on success")
  func deletionRequiresServerSuccess() async throws {
    let transport = AccountTestTransport([
      try tokenResponse(), .response(.init(data: Data(), statusCode: 503)),
      try response(accountTestUser()), .response(.init(data: Data(), statusCode: 204))
    ])
    let client = try localClient(transport: transport)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    await #expect(throws: AccountError.httpStatus(503)) { try await client.deleteAccount() }
    #expect(try await client.restore() == accountTestUser())
    try await client.deleteAccount()
    #expect(try await client.restore() == nil)
  }

  @Test("Session records are isolated by environment and server")
  func credentialNamespaces() async throws {
    let vault = AccountTestVault()
    let transport = AccountTestTransport([try tokenResponse()])
    let original = try localClient(transport: transport, vault: vault)
    _ = try await original.signIn(request: appleRequest(), appleUserID: "apple-sub")
    for configuration in [
      EventClientConfiguration(environment: .localhost, baseURL: try url("https://other.example.com")),
      EventClientConfiguration(environment: .production, baseURL: try url("http://localhost:8080"))
    ] {
      let other = AccountClient(configuration: configuration, apiKey: "test-key", transport: transport, vault: vault)
      #expect(try await other.restore() == nil)
    }
    #expect(await transport.requests.count == 1)
  }

  @Test("Unsupported production devices use real Apple exchange and bearer-authenticated requests")
  func unsupportedProductionUsesRealAuthentication() async throws {
    let transport = AccountTestTransport([
      try tokenResponse(), try response(accountTestUser()),
      .response(.init(data: Data("created".utf8), statusCode: 201))
    ])
    let vault = AccountTestVault()
    let device = AccountTestAttestation(isSupported: false)
    let client = AccountClient(
      configuration: .init(environment: .production, baseURL: try url("https://api.example.com")),
      apiKey: "test-key", transport: transport, vault: vault,
      attestation: device)
    #expect(client.availabilityError == nil)
    #expect(client.configurationReady && !client.isMock)
    #expect(try await client.signIn(request: appleRequest(), appleUserID: "apple-sub") == accountTestUser())
    #expect(try await client.currentUser() == accountTestUser())
    let result = try await client.authenticatedRequest(
      path: ["organizer", "events"], method: "POST", body: Data("{}".utf8))
    #expect(result == Data("created".utf8))
    await #expect(throws: AccountError.invalidRequest) { try await client.signInMock() }
    let requests = await transport.requests
    #expect(requests.map { $0.url?.path } == ["/auth/apple", "/me", "/organizer/events"])
    #expect(requests.allSatisfy { $0.value(forHTTPHeaderField: "X-Attest-Assertion") == nil })
    #expect(requests.allSatisfy { $0.value(forHTTPHeaderField: "X-API-Key") == "test-key" })
    #expect(requests.first?.value(forHTTPHeaderField: "Authorization") == nil)
    #expect(requests.dropFirst().allSatisfy { $0.value(forHTTPHeaderField: "Authorization") == "Bearer access-1" })
    let posted = try JSONDecoder().decode(AppleSignInRequest.self, from: #require(requests.first?.httpBody))
    #expect(posted == appleRequest())
    #expect(await device.generatedKeys == 0)
    #expect(vault.accesses > 0)
  }

  @Test("Production still requires valid server configuration")
  func productionRequiresConfiguration() async throws {
    let transport = AccountTestTransport([])
    let vault = AccountTestVault()
    let missing = AccountClient(
      configuration: .init(environment: .production), apiKey: "", transport: transport, vault: vault)
    #expect(!missing.configurationReady)
    #expect(missing.availabilityError == .notConfigured)
    await #expect(throws: AccountError.notConfigured) {
      try await missing.signIn(request: appleRequest(), appleUserID: "apple-sub")
    }
    #expect(await transport.requests.isEmpty)
  }

  @Test("A supported device never falls back to an unverified request after attestation rejection")
  func rejectedAttestationDoesNotFallBack() async throws {
    let bytes = Data("challenge-with-enough-bytes".utf8)
    let invalid = Data(#"{"error":true,"reason":"Invalid App Attest assertion."}"#.utf8)
    let transport = AccountTestTransport([
      try challenge(bytes), .response(.init(data: Data(), statusCode: 201)),
      try challenge(bytes), .response(.init(data: invalid, statusCode: 401))
    ])
    let client = AccountClient(
      configuration: .init(environment: .production, baseURL: try url("https://api.example.com")),
      apiKey: "test-key", transport: transport, vault: AccountTestVault(),
      attestation: AccountTestAttestation(isSupported: true))
    await #expect(throws: AccountError.httpStatus(401, reason: "Invalid App Attest assertion.")) {
      try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    }
    let requests = await transport.requests
    #expect(requests.count == 4)
    let exchanges = requests.filter { $0.url?.path == "/auth/apple" }
    #expect(exchanges.count == 1)
    #expect(exchanges.first?.value(forHTTPHeaderField: "X-Attest-Assertion") != nil)
    #expect(try await client.restore() == nil)
  }

  @Test("App Attest registers once and signs the exact bytes sent in serialized round trips")
  func attestationMatchesWireBytes() async throws {
    let challenges = (0..<4).map { Data("challenge-number-\($0)".utf8) }
    let transport = AccountTestTransport(
      [
        try challenge(challenges[0]), .response(.init(data: Data(), statusCode: 201)),
        try challenge(challenges[1]), try tokenResponse(),
        try challenge(challenges[2]), .response(.init(data: Data("first".utf8), statusCode: 200)),
        try challenge(challenges[3]), .response(.init(data: Data("second".utf8), statusCode: 200))
      ], delay: .milliseconds(5))
    let device = AccountTestAttestation(isSupported: true)
    let client = AccountClient(
      configuration: .init(environment: .production, baseURL: try url("https://api.example.com")),
      apiKey: "test-key", transport: transport, vault: AccountTestVault(), attestation: device)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    async let first = client.authenticatedRequest(
      path: ["events", "a/b + c"], method: "POST", body: Data(#"{"title":"Olá"}"#.utf8))
    async let second = client.authenticatedRequest(
      path: ["events", "other"], method: "PATCH", body: Data(#"{"title":"Outro"}"#.utf8))
    _ = try await [first, second]
    let requests = await transport.requests
    let protected = requests.filter { $0.value(forHTTPHeaderField: "X-Attest-Assertion") != nil }
    #expect(protected.count == 3)
    let expectedHashes = zip(challenges.dropFirst(), protected).map {
      Data(SHA256.hash(data: $0.0 + ($0.1.httpBody ?? Data())))
    }
    #expect(await device.assertionHashes == expectedHashes)
    #expect(await device.attestationHashes == [Data(SHA256.hash(data: challenges[0]))])
    #expect(await device.generatedKeys == 1)
    #expect(await transport.maximumConcurrent == 1)
    #expect(protected.contains { $0.url?.absoluteString.contains("a%2Fb%20%2B%20c") == true })
    #expect(protected.dropFirst().allSatisfy { $0.value(forHTTPHeaderField: "Authorization") == "Bearer access-1" })
  }

  @Test("A forbidden mutation preserves the server reason and never replays the write")
  func mutationFailureIsNotRetried() async throws {
    let failure = Data(#"{"error":true,"reason":"Você não organiza este capítulo."}"#.utf8)
    let transport = AccountTestTransport([try tokenResponse(), .response(.init(data: failure, statusCode: 403))])
    let client = try localClient(transport: transport)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    do {
      _ = try await client.authenticatedRequest(path: ["organizer", "events"], method: "POST", body: Data("{}".utf8))
      Issue.record("Expected denied organizer access")
    } catch let error as AccountClientError {
      #expect(error.statusCode == 403)
      #expect(error.localizedDescription == "Você não organiza este capítulo.")
    }
    #expect(await transport.requests.count == 2)
  }

  @Test("A server that lost its device key can recover on the next explicit sign-in")
  func forgottenAttestedKeyRecovers() async throws {
    let bytes = Data("challenge-with-enough-bytes".utf8)
    let missing = Data(#"{"error":true,"reason":"Unknown App Attest key."}"#.utf8)
    let transport = AccountTestTransport([
      try challenge(bytes), .response(.init(data: Data(), statusCode: 201)),
      try challenge(bytes), try tokenResponse(),
      try challenge(bytes), .response(.init(data: missing, statusCode: 401)),
      try challenge(bytes), .response(.init(data: Data(), statusCode: 201)),
      try challenge(bytes), try tokenResponse(suffix: "2")
    ])
    let device = AccountTestAttestation(isSupported: true)
    let client = AccountClient(
      configuration: .init(environment: .production, baseURL: try url("https://api.example.com")),
      apiKey: "test-key", transport: transport, vault: AccountTestVault(), attestation: device)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    #expect(try await client.restore() == nil)
    #expect(await transport.requests.count == 6)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    #expect(await device.generatedKeys == 2)
    #expect(await transport.requests.count == 10)
  }

  @Test("An unauthorized current-user response clears the restored session")
  func unauthorizedCurrentUser() async throws {
    let transport = AccountTestTransport([
      try tokenResponse(), .response(.init(data: Data(), statusCode: 401))
    ])
    let client = try localClient(transport: transport)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    #expect(try await client.restore() == nil)
    #expect(await client.appleUserID() == nil)
    #expect(await transport.requests.count == 2)
  }

  @Test("An unauthorized mutation clears credentials without replaying it")
  func unauthorizedMutation() async throws {
    let transport = AccountTestTransport([
      try tokenResponse(), .response(.init(data: Data(), statusCode: 401))
    ])
    let client = try localClient(transport: transport)
    _ = try await client.signIn(request: appleRequest(), appleUserID: "apple-sub")
    await #expect(throws: AccountError.authenticationRequired) {
      try await client.authenticatedRequest(path: ["organizer", "events"], method: "POST", body: Data("{}".utf8))
    }
    #expect(try await client.restore() == nil)
    #expect(await transport.requests.count == 2)
  }

  @Test("A successful exchange saves its credentials even when the presenting task was cancelled")
  func completedExchangeSurvivesCancellation() async throws {
    let token = TokenResponse(
      accessToken: "access-1", refreshToken: "refresh-1", expiresIn: 900, user: accountTestUser())
    let transport = AccountTestTransport([
      .cancelledResponse(.init(data: try JSONEncoder().encode(token), statusCode: 200)),
      try response(accountTestUser())
    ])
    let vault = AccountTestVault()
    let client = try localClient(transport: transport, vault: vault)
    let exchange = Task { try await client.signIn(request: appleRequest(), appleUserID: "apple-sub") }
    #expect(try await exchange.value == accountTestUser())
    #expect(exchange.isCancelled)
    let reopened = try localClient(transport: transport, vault: vault)
    #expect(try await reopened.restore() == accountTestUser())
  }

  private func localClient(
    transport: AccountTestTransport, vault: AccountTestVault = AccountTestVault()
  ) throws -> AccountClient {
    AccountClient(
      configuration: .init(environment: .localhost, baseURL: try url("http://localhost:8080")),
      apiKey: "test-key", transport: transport, vault: vault,
      attestation: AccountTestAttestation(isSupported: false))
  }

  private func appleRequest() -> AppleSignInRequest {
    AppleSignInRequest(identityToken: "apple-token", authorizationCode: "apple-code", nonce: "raw-nonce")
  }

  private func url(_ value: String) throws -> URL { try #require(URL(string: value)) }

  private func tokenResponse(expiresIn: Int = 900, suffix: String = "1") throws -> AccountTestTransport.Step {
    try response(
      TokenResponse(
        accessToken: "access-\(suffix)", refreshToken: "refresh-\(suffix)",
        expiresIn: expiresIn, user: accountTestUser()))
  }

  private func challenge(_ bytes: Data) throws -> AccountTestTransport.Step {
    try response(AttestChallengeResponse(challenge: bytes.base64EncodedString(), expiresIn: 300))
  }

  private func response(_ value: some Encodable) throws -> AccountTestTransport.Step {
    .response(.init(data: try JSONEncoder().encode(value), statusCode: 200, contentType: "application/json"))
  }
}

private func accountTestUser() -> UserDTO {
  UserDTO(
    id: UUID(uuidString: "00000000-0000-0000-0000-000000000042") ?? UUID(),
    fullName: "Organizador", role: .organizer)
}

private actor AccountTestTransport: EventHTTPTransport {
  enum Step: Sendable {
    case response(EventHTTPResponse)
    case cancelledResponse(EventHTTPResponse)
    case failure(URLError.Code)
  }

  private var steps: [Step]
  private let delay: Duration
  private var concurrent = 0
  private(set) var requests: [URLRequest] = []
  private(set) var maximumConcurrent = 0

  init(_ steps: [Step], delay: Duration = .zero) {
    self.steps = steps
    self.delay = delay
  }

  func data(for request: URLRequest) async throws -> EventHTTPResponse {
    requests.append(request)
    concurrent += 1
    maximumConcurrent = max(maximumConcurrent, concurrent)
    defer { concurrent -= 1 }
    guard !steps.isEmpty else { throw AccountError.invalidResponse }
    let step = steps.removeFirst()
    if delay != .zero { try await Task.sleep(for: delay) }
    switch step {
    case .response(let response): return response
    case .cancelledResponse(let response):
      withUnsafeCurrentTask { $0?.cancel() }
      return response
    case .failure(let code): throw URLError(code)
    }
  }
}

private final class AccountTestVault: AccountCredentialVault, Sendable {
  private struct State {
    var values: [String: Data] = [:]
    var accesses = 0
  }
  private let state = Mutex(State())
  var accesses: Int { state.withLock { $0.accesses } }

  func read(key: String) throws -> Data? {
    state.withLock {
      $0.accesses += 1
      return $0.values[key]
    }
  }

  func write(_ data: Data, key: String) throws {
    state.withLock {
      $0.accesses += 1
      $0.values[key] = data
    }
  }

  func remove(key: String) throws {
    state.withLock {
      $0.accesses += 1
      $0.values[key] = nil
    }
  }
}

private actor AccountTestAttestation: AccountAttestation {
  nonisolated let isSupported: Bool
  private(set) var generatedKeys = 0
  private(set) var attestationHashes: [Data] = []
  private(set) var assertionHashes: [Data] = []

  init(isSupported: Bool) { self.isSupported = isSupported }

  func generateKey() async throws -> String {
    generatedKeys += 1
    return Data("device-key".utf8).base64EncodedString()
  }

  func attestKey(_ keyID: String, clientDataHash: Data) async throws -> Data {
    attestationHashes.append(clientDataHash)
    return Data("attestation".utf8)
  }

  func generateAssertion(_ keyID: String, clientDataHash: Data) async throws -> Data {
    assertionHashes.append(clientDataHash)
    return Data("assertion-\(assertionHashes.count)".utf8)
  }
}
