import CocoaHeadsCore
import JWT
import Testing
import VaporTesting

@testable import backend

private let nonceDigest = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"

private func appleIdentity(
  subject: String = "apple-user", audience: String = "com.cocoaheadsbr.conf", nonce: String? = nonceDigest
) -> AppleIdentityToken {
  AppleIdentityToken(
    issuer: IssuerClaim(value: "https://appleid.apple.com"),
    audience: AudienceClaim(value: audience),
    expires: ExpirationClaim(value: Date().addingTimeInterval(300)),
    issuedAt: IssuedAtClaim(value: Date()), subject: SubjectClaim(value: subject),
    nonce: nonce, email: "member@example.com")
}

private struct AppleAuthStub: AppleAuthServiceProtocol {
  let original: AppleIdentityToken
  let exchanged: AppleIdentityToken

  func verifyIdentityToken(_ token: String, on req: Request) async throws -> AppleIdentityToken {
    switch token {
    case "identity": return original
    case "exchanged": return exchanged
    default: throw Abort(.unauthorized)
    }
  }

  func exchangeAuthorizationCode(_ code: String, on req: Request) async throws -> AppleAuthorizationGrant {
    #expect(code == "authorization-code")
    return AppleAuthorizationGrant(refreshToken: "apple-refresh", identityToken: "exchanged")
  }

  func revokeRefreshToken(_ appleRefreshToken: String, on req: Request) async throws {}
}

@Suite("Apple sign-in identity binding")
struct AppleSignInValidationTests {
  @Test("A valid identity and exchanged grant share the raw nonce digest and subject")
  func validIdentity() throws {
    let identity = appleIdentity()
    try AppleSignInValidation.validate(identity, rawNonce: "abc", audience: "com.cocoaheadsbr.conf")
    try AppleSignInValidation.match(identity, exchangedIdentity: appleIdentity())
  }

  @Test(
    "Sign-in rejects invalid identity binding before writing a user or tokens",
    arguments: [
      "missingNonce", "blankNonce", "firstNonce", "missingTokenNonce", "firstAudience",
      "exchangedNonce", "exchangedAudience", "differentSubject"
    ])
  func invalidSignIn(variation: String) async throws {
    var nonce: String? = "abc"
    var original = appleIdentity()
    var exchanged = appleIdentity()
    switch variation {
    case "missingNonce": nonce = nil
    case "blankNonce": nonce = " \n\t "
    case "firstNonce": original = appleIdentity(nonce: "wrong")
    case "missingTokenNonce": original = appleIdentity(nonce: nil)
    case "firstAudience": original = appleIdentity(audience: "another-app")
    case "exchangedNonce": exchanged = appleIdentity(nonce: "wrong")
    case "exchangedAudience": exchanged = appleIdentity(audience: "another-app")
    default: exchanged = appleIdentity(subject: "another-user")
    }
    let body = AppleSignInRequest(
      identityToken: "identity", authorizationCode: "authorization-code", nonce: nonce)
    let expected: HTTPResponseStatus = ["missingNonce", "blankNonce"].contains(variation) ? .badRequest : .unauthorized
    let app = try await Application.make(.testing)
    do {
      app.authConfiguration = AuthConfiguration.load(from: .testing) { key in
        ["APPLE_TEAM_ID": "TEAM", "APPLE_SIGNIN_KEY_ID": "KEY", "APPLE_SIGNIN_PRIVATE_KEY": "configured"][key]
      }
      try app.register(collection: AuthController(appleAuth: AppleAuthStub(original: original, exchanged: exchanged)))
      // No database or encryption service is configured: rejection must happen first.
      try await app.testing().test(
        .POST, "auth/apple",
        beforeRequest: { request in
          request.body = try ByteBuffer(data: JSONEncoder().encode(body))
          request.headers.contentType = .json
        },
        afterResponse: { response in
          #expect(response.status == expected)
        })
    } catch {
      try? await app.asyncShutdown()
      throw error
    }
    try await app.asyncShutdown()
  }
}

@Suite("Authentication environment settings")
struct AuthEnvironmentTests {
  @Test("Compose's blank values are treated as missing credentials")
  func blankValues() {
    let configuration = AuthConfiguration.load(from: .testing, read: { _ in " \n\t " })
    #expect(configuration.appleBundleID == "com.cocoaheadsbr.conf")
    #expect(configuration.apiKeys.isEmpty)
    #expect(!configuration.hasAppleServiceCredentials)
    #expect(configuration.appleTeamID == nil)
    #expect(configuration.accessTokenTTL == 900)
    #expect(AuthEnvironment.nonEmpty(" \n\t ") == nil)
  }

  @Test("Configured values are trimmed and retain PEM line breaks")
  func validValues() {
    let configuration = AuthConfiguration.load(from: .testing) { key in
      [
        "APPLE_BUNDLE_ID": " example.app ", "API_KEYS": " first, \n second, , ",
        "APPLE_TEAM_ID": " TEAM ",
        "APPLE_SIGNIN_KEY_ID": " KEY ", "APPLE_SIGNIN_PRIVATE_KEY": " \nBEGIN\nKEY\nEND\n ",
        "ACCESS_TOKEN_TTL": " 1200 "
      ][key]
    }
    #expect(configuration.appleBundleID == "example.app")
    #expect(configuration.apiKeys == ["first", "second"])
    #expect(configuration.appleTeamID == "TEAM")
    #expect(configuration.hasAppleServiceCredentials)
    #expect(configuration.appleSignInPrivateKey == "BEGIN\nKEY\nEND")
    #expect(configuration.accessTokenTTL == 1200)
  }
}
