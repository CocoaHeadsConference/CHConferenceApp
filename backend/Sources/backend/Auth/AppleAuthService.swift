//
//  AppleAuthService.swift
//  backend
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import JWT
import Vapor

/// Server-to-server client for Apple's Sign in with Apple endpoints:
/// exchanging the authorization code for Apple tokens at sign-in (§4) and
/// revoking the user's grant at account deletion (§8).
protocol AppleAuthServiceProtocol: Sendable {
  func verifyIdentityToken(_ token: String, on req: Request) async throws -> AppleIdentityToken

  /// Exchanges the single-use `authorizationCode` for Apple's token set.
  /// Both tokens are needed to bind the stored grant to the signed-in identity.
  func exchangeAuthorizationCode(_ code: String, on req: Request) async throws -> AppleAuthorizationGrant

  /// Revokes the user's Sign in with Apple grant using the stored Apple
  /// refresh token.
  func revokeRefreshToken(_ appleRefreshToken: String, on req: Request) async throws
}

struct AppleAuthorizationGrant: Sendable {
  let refreshToken: String
  let identityToken: String
}

struct AppleAuthService: AppleAuthServiceProtocol {
  static let tokenURL = URI(string: "https://appleid.apple.com/auth/token")
  static let revokeURL = URI(string: "https://appleid.apple.com/auth/revoke")

  func verifyIdentityToken(_ token: String, on req: Request) async throws -> AppleIdentityToken {
    try await req.jwt.apple.verify(token, applicationIdentifier: req.authConfiguration.appleBundleID)
  }

  func exchangeAuthorizationCode(_ code: String, on req: Request) async throws -> AppleAuthorizationGrant {
    let config = req.authConfiguration
    let clientSecret = try await makeClientSecret(config: config)

    let response = try await req.client.post(Self.tokenURL) { clientReq in
      try clientReq.content.encode(
        AppleTokenRequest(
          clientId: config.appleBundleID,
          clientSecret: clientSecret,
          code: code,
          grantType: "authorization_code"
        ),
        as: .urlEncodedForm
      )
    }

    guard response.status == .ok else {
      let body = response.body.map { String(buffer: $0) } ?? "<empty>"
      req.logger.error("Apple token exchange failed: \(response.status) \(body)")
      throw Abort(.unauthorized, reason: "Apple rejected the authorization code.")
    }

    let tokens = try response.content.decode(AppleTokenResponse.self)
    guard let identityToken = tokens.idToken,
      !identityToken.isEmpty, !tokens.refreshToken.isEmpty
    else { throw Abort(.unauthorized, reason: "Apple returned an incomplete authorization grant.") }
    return AppleAuthorizationGrant(refreshToken: tokens.refreshToken, identityToken: identityToken)
  }

  func revokeRefreshToken(_ appleRefreshToken: String, on req: Request) async throws {
    let config = req.authConfiguration
    let clientSecret = try await makeClientSecret(config: config)

    let response = try await req.client.post(Self.revokeURL) { clientReq in
      try clientReq.content.encode(
        AppleRevokeRequest(
          clientId: config.appleBundleID,
          clientSecret: clientSecret,
          token: appleRefreshToken,
          tokenTypeHint: "refresh_token"
        ),
        as: .urlEncodedForm
      )
    }

    guard response.status == .ok else {
      let body = response.body.map { String(buffer: $0) } ?? "<empty>"
      req.logger.error("Apple token revocation failed: \(response.status) \(body)")
      throw Abort(.internalServerError, reason: "Apple token revocation failed.")
    }
  }

  /// Builds the client-secret JWT Apple requires, signed with the Sign in with
  /// Apple `.p8` key (ES256).
  private func makeClientSecret(config: AuthConfiguration) async throws -> String {
    guard
      let teamID = config.appleTeamID,
      let keyID = config.appleSignInKeyID,
      let privateKeyPEM = config.appleSignInPrivateKey
    else {
      throw Abort(
        .internalServerError,
        reason: "Sign in with Apple service credentials are not configured."
      )
    }

    let keys = JWTKeyCollection()
    let kid = JWKIdentifier(string: keyID)
    try await keys.add(ecdsa: ES256PrivateKey(pem: privateKeyPEM), kid: kid)

    let now = Date()
    let payload = AppleClientSecretPayload(
      issuer: IssuerClaim(value: teamID),
      issuedAt: IssuedAtClaim(value: now),
      expiration: ExpirationClaim(value: now.addingTimeInterval(300)),
      audience: AudienceClaim(value: "https://appleid.apple.com"),
      subject: SubjectClaim(value: config.appleBundleID)
    )
    return try await keys.sign(payload, kid: kid)
  }
}

struct AppleClientSecretPayload: JWTPayload {
  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case issuedAt = "iat"
    case expiration = "exp"
    case audience = "aud"
    case subject = "sub"
  }

  let issuer: IssuerClaim
  let issuedAt: IssuedAtClaim
  let expiration: ExpirationClaim
  let audience: AudienceClaim
  let subject: SubjectClaim

  func verify(using algorithm: some JWTAlgorithm) async throws {
    try expiration.verifyNotExpired()
  }
}

private struct AppleTokenRequest: Content {
  enum CodingKeys: String, CodingKey {
    case clientId = "client_id"
    case clientSecret = "client_secret"
    case code
    case grantType = "grant_type"
  }

  let clientId: String
  let clientSecret: String
  let code: String
  let grantType: String
}

private struct AppleTokenResponse: Content {
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case idToken = "id_token"
    case expiresIn = "expires_in"
    case tokenType = "token_type"
  }

  let accessToken: String
  let refreshToken: String
  let idToken: String?
  let expiresIn: Int?
  let tokenType: String?
}

private struct AppleRevokeRequest: Content {
  enum CodingKeys: String, CodingKey {
    case clientId = "client_id"
    case clientSecret = "client_secret"
    case token
    case tokenTypeHint = "token_type_hint"
  }

  let clientId: String
  let clientSecret: String
  let token: String
  let tokenTypeHint: String
}
