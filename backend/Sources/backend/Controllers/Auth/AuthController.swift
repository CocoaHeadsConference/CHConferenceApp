//
//  AuthController.swift
//  backend
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import CocoaHeadsCore
import Fluent
import Vapor

/// Sign in with Apple + session-token endpoints (§4, §5).
struct AuthController: RouteCollection {
  let appleAuth: any AppleAuthServiceProtocol
  let tokens = TokenService()

  func boot(routes: any RoutesBuilder) throws {
    let auth = routes.grouped("auth")
    auth.post("apple", use: signInWithApple)
    auth.post("refresh", use: refresh)
    auth.grouped(AccessTokenPayload.authenticator(), AccessTokenPayload.guardMiddleware())
      .post("logout", use: logout)
  }

  /// Sign in / sign up. Verifies the Apple identity token, upserts the user,
  /// exchanges the authorization code for Apple's refresh token (required for
  /// account-deletion revocation, §8), and issues a backend token pair.
  @Sendable
  func signInWithApple(req: Request) async throws -> TokenResponse {
    let config = req.authConfiguration
    let signIn = try req.content.decode(AppleSignInRequest.self)
    let rawNonce = try AppleSignInValidation.requireNonce(signIn.nonce)
    let identity = try await appleAuth.verifyIdentityToken(signIn.identityToken, on: req)
    try AppleSignInValidation.validate(identity, rawNonce: rawNonce, audience: config.appleBundleID)

    // Exchanging the code for Apple's refresh token is mandatory groundwork
    // for account deletion (§8). Local development without the `.p8` service
    // credentials may skip it — never production.
    let encryptedRefreshToken: String?
    if config.hasAppleServiceCredentials {
      let grant = try await appleAuth.exchangeAuthorizationCode(
        signIn.authorizationCode,
        on: req
      )
      let exchangedIdentity = try await appleAuth.verifyIdentityToken(grant.identityToken, on: req)
      try AppleSignInValidation.validate(exchangedIdentity, rawNonce: rawNonce, audience: config.appleBundleID)
      try AppleSignInValidation.match(identity, exchangedIdentity: exchangedIdentity)
      encryptedRefreshToken = try req.application.tokenEncryption.encrypt(grant.refreshToken)
    } else if req.application.environment != .production {
      req.logger.warning(
        "Apple service credentials not configured — skipping authorization-code exchange. Account deletion cannot revoke Apple's grant for this sign-in."
      )
      encryptedRefreshToken = nil
    } else {
      throw Abort(
        .internalServerError,
        reason: "Sign in with Apple service credentials are not configured."
      )
    }

    let user = try await AppleUserService().signIn(
      appleIdentifier: identity.subject.value, email: identity.email ?? signIn.email,
      fullName: signIn.fullName, encryptedRefreshToken: encryptedRefreshToken, on: req.db)

    // Associate the attested device key with the signed-in user.
    if let attestedKeyID = req.attestedKeyID {
      try await AppAttestKey.query(on: req.db)
        .filter(\.$keyId == attestedKeyID)
        .set(\.$user.$id, to: user.id)
        .update()
    }

    return try await tokens.issueTokenPair(for: user, on: req)
  }

  /// Single-use refresh-token rotation.
  @Sendable
  func refresh(req: Request) async throws -> TokenResponse {
    let body = try req.content.decode(RefreshRequest.self)
    return try await tokens.rotate(refreshToken: body.refreshToken, on: req)
  }

  /// Revokes the presented refresh token.
  @Sendable
  func logout(req: Request) async throws -> HTTPStatus {
    let body = try req.content.decode(RefreshRequest.self)
    try await tokens.revoke(refreshToken: body.refreshToken, on: req)
    return .noContent
  }
}

extension RefreshRequest: @retroactive RequestDecodable {}
extension RefreshRequest: @retroactive ResponseEncodable {}
extension RefreshRequest: @retroactive AsyncRequestDecodable {}
extension RefreshRequest: @retroactive AsyncResponseEncodable {}
extension RefreshRequest: @retroactive Content {}

extension TokenResponse: @retroactive RequestDecodable {}
extension TokenResponse: @retroactive ResponseEncodable {}
extension TokenResponse: @retroactive AsyncRequestDecodable {}
extension TokenResponse: @retroactive AsyncResponseEncodable {}
extension TokenResponse: @retroactive Content {}
