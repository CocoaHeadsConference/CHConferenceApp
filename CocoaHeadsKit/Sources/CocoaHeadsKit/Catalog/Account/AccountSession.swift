import AuthenticationServices
import CocoaHeadsCore
import CocoaHeadsNetworking
import CryptoKit
import Observation
import SwiftUI

/// Presentation state shared by every window. Credentials live in AccountClient's Keychain vault.
@MainActor @Observable
final class AccountSession {
  let client: AccountClient
  var user: UserDTO?
  var errorMessage: String?
  var isAuthorizing: Bool { authorization != nil }
  var isBusy: Bool { isAuthorizing || busyGeneration != nil }

  private struct AppleAttempt {
    let nonce: String
    let state: String
    let generation: UInt64
  }

  private let credentialState: @Sendable (String) async throws -> ASAuthorizationAppleIDProvider.CredentialState
  private var restored = false
  private var refreshing = false
  private var generation: UInt64 = 0
  private var busyGeneration: UInt64?
  private var authorization: AppleAttempt?

  init(
    client: AccountClient,
    credentialState: @escaping @Sendable (String) async throws -> ASAuthorizationAppleIDProvider.CredentialState = {
      try await ASAuthorizationAppleIDProvider().credentialState(forUserID: $0)
    }
  ) {
    self.client = client
    self.credentialState = credentialState
  }

  func restore() async {
    guard !restored else { return }
    restored = true
    await refresh()
  }

  func refresh() async {
    guard !refreshing, !isBusy else { return }
    let expectedGeneration = generation
    refreshing = true
    defer { refreshing = false }
    do {
      if !client.isMock, let appleID = await client.appleUserID() {
        guard generation == expectedGeneration else { return }
        let state = try await credentialState(appleID)
        guard generation == expectedGeneration else { return }
        if state == .revoked || state == .notFound {
          await revoked()
          return
        }
      }
      guard generation == expectedGeneration else { return }
      let restoredUser = try await client.restore()
      guard generation == expectedGeneration else { return }
      user = restoredUser
      errorMessage = nil
    } catch is CancellationError {
      return
    } catch {
      guard generation == expectedGeneration else { return }
      errorMessage = error.localizedDescription
      if OrganizerPresentationError.requiresSignIn(error) {
        await revoked()
      }
    }
  }

  func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
    guard !isBusy else { return }
    generation &+= 1
    errorMessage = nil
    let rawNonce = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0).base64EncodedString() }
    let attempt = AppleAttempt(nonce: rawNonce, state: UUID().uuidString, generation: generation)
    authorization = attempt
    request.requestedScopes = [.fullName, .email]
    request.nonce = SHA256.hash(data: Data(rawNonce.utf8)).map { String(format: "%02x", $0) }.joined()
    request.state = attempt.state
  }

  func completeAppleRequest(_ result: Result<ASAuthorization, any Error>) async {
    guard let attempt = authorization, generation == attempt.generation else { return }
    defer {
      if authorization?.generation == attempt.generation { authorization = nil }
    }
    switch result {
    case .failure(let error):
      if (error as? ASAuthorizationError)?.code != .canceled {
        errorMessage = error.localizedDescription
      }
    case .success(let authorization):
      guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
        credential.state == attempt.state,
        let token = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }),
        let code = credential.authorizationCode.flatMap({ String(data: $0, encoding: .utf8) })
      else {
        errorMessage = "Não foi possível confirmar sua identidade com a Apple. Tente entrar novamente."
        return
      }
      do {
        let name = credential.fullName.map {
          PersonNameComponentsFormatter.localizedString(from: $0, style: .default)
        }
        let signedInUser = try await client.signIn(
          request: AppleSignInRequest(
            identityToken: token, authorizationCode: code,
            fullName: name, email: credential.email, nonce: attempt.nonce),
          appleUserID: credential.user)
        guard generation == attempt.generation else { return }
        user = signedInUser
        errorMessage = nil
      } catch {
        guard generation == attempt.generation else { return }
        errorMessage = error.localizedDescription
      }
    }
  }

  func signOut() async {
    guard !isBusy else { return }
    let operation = beginAccountChange()
    user = nil
    defer { finishAccountChange(operation) }
    do {
      try await client.signOut()
      guard generation == operation else { return }
      errorMessage = nil
    } catch {
      guard generation == operation else { return }
      errorMessage = error.localizedDescription
    }
  }

  func deleteAccount() async {
    guard !isBusy else { return }
    let operation = beginAccountChange()
    defer { finishAccountChange(operation) }
    do {
      try await client.deleteAccount()
      guard generation == operation else { return }
      user = nil
      errorMessage = nil
    } catch {
      guard generation == operation else { return }
      errorMessage = error.localizedDescription
      if OrganizerPresentationError.requiresSignIn(error) { await revoked() }
    }
  }

  func revoked() async {
    let operation = beginAccountChange()
    authorization = nil
    user = nil
    defer { finishAccountChange(operation) }
    do { try await client.clearLocalSession() } catch {
      guard generation == operation else { return }
      errorMessage = error.localizedDescription
    }
  }

  #if DEBUG
    func signInMock(role: UserRole) async {
      guard client.isMock, !isBusy else { return }
      let operation = beginAccountChange()
      defer { finishAccountChange(operation) }
      do {
        let signedInUser = try await client.signInMock(role: role)
        guard generation == operation else { return }
        user = signedInUser
        errorMessage = nil
      } catch {
        guard generation == operation else { return }
        errorMessage = error.localizedDescription
      }
    }
  #endif

  private func beginAccountChange() -> UInt64 {
    generation &+= 1
    busyGeneration = generation
    return generation
  }

  private func finishAccountChange(_ operation: UInt64) {
    if busyGeneration == operation { busyGeneration = nil }
  }

}

extension UserRole {
  var localizedTitle: String {
    switch self {
    case .user: "Participante"
    case .organizer: "Organizador"
    case .admin: "Administrador"
    }
  }
}
