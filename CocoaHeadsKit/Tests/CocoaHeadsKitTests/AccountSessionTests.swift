import AuthenticationServices
import CocoaHeadsCore
import CocoaHeadsNetworking
import Foundation
import Synchronization
import Testing

@testable import CocoaHeadsKit

@MainActor
@Suite("Account presentation lifecycle")
struct AccountSessionTests {
  @Test("An uncertain refresh clears organizer presentation and returns to sign-in")
  func uncertainRefreshReturnsToSignIn() async throws {
    let (session, _) = try await harness(expiresIn: 1, responses: [.failure(.timedOut)])
    await session.refresh()
    #expect(session.user == nil)
    #expect(session.errorMessage == AccountError.refreshUncertain.localizedDescription)
    #expect(!session.isBusy)
    #expect(try await session.client.restore() == nil)
  }

  @Test("A credential check started before logout cannot restore the signed-out user")
  func staleRefreshCannotUndoSignOut() async throws {
    let probe = CredentialStateProbe()
    let (session, transport) = try await harness(
      responses: [.response(.init(data: Data(), statusCode: 204))],
      credentialState: { _ in try await probe.value() })
    let refresh = Task { await session.refresh() }
    await probe.waitUntilRequested()
    await session.signOut()
    await probe.resolve(.success(.authorized))
    await refresh.value
    #expect(session.user == nil)
    #expect(session.errorMessage == nil)
    #expect(try await session.client.restore() == nil)
    #expect(await transport.requests.map { $0.url?.path } == ["/auth/apple", "/auth/logout"])
  }

  @Test("An old refresh failure cannot clear a newer Apple authorization")
  func staleErrorDoesNotInvalidateNewAuthorization() async throws {
    let probe = CredentialStateProbe()
    let (session, _) = try await harness(
      responses: [.response(.init(data: Data(), statusCode: 204))],
      credentialState: { _ in try await probe.value() })
    let refresh = Task { await session.refresh() }
    await probe.waitUntilRequested()
    await session.signOut()
    let request = ASAuthorizationAppleIDProvider().createRequest()
    session.prepareAppleRequest(request)
    await probe.resolve(.failure(AccountError.refreshUncertain))
    await refresh.value
    #expect(session.isAuthorizing)
    #expect(session.errorMessage == nil)
    await session.completeAppleRequest(.failure(cancelledAuthorization()))
    #expect(!session.isBusy)
  }

  @Test("A missing Apple credential removes the local account without calling the backend")
  func missingCredentialClearsAccount() async throws {
    let (session, transport) = try await harness(responses: [], credentialState: { _ in .notFound })
    await session.refresh()
    #expect(session.user == nil)
    #expect(try await session.client.restore() == nil)
    #expect(await transport.requests.count == 1)
  }

  @Test("Transient failures preserve the account and a successful role refresh clears the error")
  func roleRefreshRecoversFromOffline() async throws {
    let updatedUser = testUser(role: .admin)
    let (session, _) = try await harness(responses: [
      .failure(.notConnectedToInternet),
      .response(.init(data: try JSONEncoder().encode(updatedUser), statusCode: 200))
    ])
    await session.refresh()
    #expect(session.user?.role == .organizer)
    #expect(session.errorMessage != nil)
    await session.refresh()
    #expect(session.user == updatedUser)
    #expect(session.errorMessage == nil)
  }

  @Test("An Apple credential-check failure preserves the account and its credentials")
  func credentialCheckFailurePreservesAccount() async throws {
    let (session, transport) = try await harness(
      responses: [], credentialState: { _ in throw URLError(.notConnectedToInternet) })
    await session.refresh()
    #expect(session.user?.role == .organizer)
    #expect(session.errorMessage != nil)
    #expect(await session.client.appleUserID() == "apple-user")
    #expect(await transport.requests.count == 1)
    #expect(!session.isBusy)
  }

  @Test("Apple authorization reserves shared state immediately and cancellation releases it")
  func authorizationLifecycle() async {
    let session = AccountSession(client: AccountClient(configuration: .init(environment: .mock), apiKey: ""))
    // Request construction is local; this test never performs an Apple authorization.
    let first = ASAuthorizationAppleIDProvider().createRequest()
    let second = ASAuthorizationAppleIDProvider().createRequest()
    session.prepareAppleRequest(first)
    #expect(session.isAuthorizing && session.isBusy)
    #expect(first.nonce?.count == 64)
    #expect(first.state != nil)
    session.prepareAppleRequest(second)
    #expect(second.nonce == nil)
    await session.completeAppleRequest(.failure(cancelledAuthorization()))
    #expect(!session.isAuthorizing && !session.isBusy)
    #expect(session.errorMessage == nil)

    session.prepareAppleRequest(second)
    #expect(second.nonce != first.nonce)
    #expect(second.state != first.state)
    await session.completeAppleRequest(.failure(URLError(.notConnectedToInternet)))
    #expect(!session.isBusy)
    #expect(session.errorMessage != nil)
  }

  private func cancelledAuthorization() -> NSError {
    NSError(domain: ASAuthorizationError.errorDomain, code: ASAuthorizationError.Code.canceled.rawValue)
  }

  private func harness(
    expiresIn: Int = 900, responses: [SessionTestTransport.Step],
    credentialState: @escaping @Sendable (String) async throws -> ASAuthorizationAppleIDProvider.CredentialState = {
      _ in .authorized
    }
  ) async throws -> (AccountSession, SessionTestTransport) {
    let user = testUser()
    let token = TokenResponse(accessToken: "access", refreshToken: "refresh", expiresIn: expiresIn, user: user)
    let transport = SessionTestTransport(
      [
        .response(.init(data: try JSONEncoder().encode(token), statusCode: 200))
      ] + responses)
    let client = AccountClient(
      configuration: .init(environment: .localhost, baseURL: try #require(URL(string: "http://localhost:8080"))),
      apiKey: "test-key", transport: transport, vault: SessionTestVault(), attestation: SessionTestAttestation())
    _ = try await client.signIn(
      request: AppleSignInRequest(identityToken: "apple-token", authorizationCode: "apple-code", nonce: "nonce"),
      appleUserID: "apple-user")
    let session = AccountSession(client: client, credentialState: credentialState)
    session.user = user
    return (session, transport)
  }

  private func testUser(role: UserRole = .organizer) -> UserDTO {
    UserDTO(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000042") ?? UUID(),
      fullName: "Organizador", role: role)
  }
}

private actor CredentialStateProbe {
  typealias State = ASAuthorizationAppleIDProvider.CredentialState
  private var result: CheckedContinuation<State, any Error>?
  private var started: [CheckedContinuation<Void, Never>] = []

  func value() async throws -> State {
    try await withCheckedThrowingContinuation {
      result = $0
      for continuation in started { continuation.resume() }
      started.removeAll()
    }
  }

  func waitUntilRequested() async {
    if result != nil { return }
    await withCheckedContinuation { started.append($0) }
  }

  func resolve(_ value: Result<State, any Error>) {
    result?.resume(with: value)
    result = nil
  }
}

private actor SessionTestTransport: EventHTTPTransport {
  enum Step: Sendable {
    case response(EventHTTPResponse)
    case failure(URLError.Code)
  }
  private var responses: [Step]
  private(set) var requests: [URLRequest] = []

  init(_ responses: [Step]) { self.responses = responses }

  func data(for request: URLRequest) async throws -> EventHTTPResponse {
    requests.append(request)
    guard !responses.isEmpty else { throw AccountError.invalidResponse }
    switch responses.removeFirst() {
    case .response(let response): return response
    case .failure(let code): throw URLError(code)
    }
  }
}

private final class SessionTestVault: AccountCredentialVault, Sendable {
  private let values = Mutex<[String: Data]>([:])
  func read(key: String) throws -> Data? { values.withLock { $0[key] } }
  func write(_ data: Data, key: String) throws { values.withLock { $0[key] = data } }
  func remove(key: String) throws { values.withLock { $0[key] = nil } }
}

private struct SessionTestAttestation: AccountAttestation {
  let isSupported = false
  func generateKey() async throws -> String { throw AccountError.invalidRequest }
  func attestKey(_ keyID: String, clientDataHash: Data) async throws -> Data { throw AccountError.invalidRequest }
  func generateAssertion(_ keyID: String, clientDataHash: Data) async throws -> Data {
    throw AccountError.invalidRequest
  }
}
