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

    let identity = try await req.jwt.apple.verify(
      signIn.identityToken,
      applicationIdentifier: config.appleBundleID
    )

    // Exchanging the code for Apple's refresh token is mandatory groundwork
    // for account deletion (§8). Local development without the `.p8` service
    // credentials may skip it — never production.
    let encryptedRefreshToken: String?
    if config.hasAppleServiceCredentials {
      let appleRefreshToken = try await appleAuth.exchangeAuthorizationCode(
        signIn.authorizationCode,
        on: req
      )
      encryptedRefreshToken = try req.application.tokenEncryption.encrypt(appleRefreshToken)
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

    var user = try await User.query(on: req.db)
      .filter(\.$appleUserIdentifier == identity.subject.value)
      .first()
      ?? User(appleUserIdentifier: identity.subject.value)

    // Name and email only arrive on the user's first authorization — persist
    // them whenever present. The email may be a Hide-My-Email relay. Prefer
    // the email from the verified identity token; the request-body value is
    // client-supplied and only a fallback (the name has no token source).
    if let email = identity.email ?? signIn.email {
      user.email = email
    }
    if let fullName = signIn.fullName {
      user.fullName = fullName
    }
    // Keep any previously stored Apple refresh token when the dev-mode
    // exchange skip produced none.
    if let encryptedRefreshToken {
      user.appleRefreshToken = encryptedRefreshToken
    }
    do {
      try await user.save(on: req.db)
    } catch let error where (error as? any DatabaseError)?.isConstraintFailure == true {
      // Two concurrent first sign-ins raced on the unique Apple `sub`; adopt
      // the row the winner created instead of failing.
      guard
        let existing = try await User.query(on: req.db)
          .filter(\.$appleUserIdentifier == identity.subject.value)
          .first()
      else { throw error }
      existing.email = user.email ?? existing.email
      existing.fullName = user.fullName ?? existing.fullName
      existing.appleRefreshToken = user.appleRefreshToken ?? existing.appleRefreshToken
      try await existing.save(on: req.db)
      user = existing
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
