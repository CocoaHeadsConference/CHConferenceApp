import CocoaHeadsCore
import Crypto
import Foundation
import JWTKit
import Testing
import VaporTesting

@testable import backend

@Suite("Access token payload")
struct AccessTokenPayloadTests {
  private func keyCollection() async -> JWTKeyCollection {
    await JWTKeyCollection().add(hmac: "test-signing-secret", digestAlgorithm: .sha256)
  }

  @Test("Signs and verifies a round trip with intact claims")
  func roundTrip() async throws {
    let keys = await keyCollection()
    let userID = UUID()
    let now = Date()
    let payload = AccessTokenPayload(
      subject: SubjectClaim(value: userID.uuidString),
      expiration: ExpirationClaim(value: now.addingTimeInterval(900)),
      issuedAt: IssuedAtClaim(value: now),
      role: .organizer
    )

    let token = try await keys.sign(payload)
    let verified = try await keys.verify(token, as: AccessTokenPayload.self)
    #expect(try verified.userID == userID)
    #expect(verified.role == .organizer)
  }

  @Test("Rejects an expired token")
  func expired() async throws {
    let keys = await keyCollection()
    let payload = AccessTokenPayload(
      subject: SubjectClaim(value: UUID().uuidString),
      expiration: ExpirationClaim(value: Date().addingTimeInterval(-60)),
      issuedAt: IssuedAtClaim(value: Date().addingTimeInterval(-960)),
      role: .user
    )

    let token = try await keys.sign(payload)
    await #expect(throws: (any Error).self) {
      try await keys.verify(token, as: AccessTokenPayload.self)
    }
  }

  @Test("Rejects a token signed with a different key")
  func wrongKey() async throws {
    let keys = await keyCollection()
    let otherKeys = await JWTKeyCollection().add(hmac: "other-secret", digestAlgorithm: .sha256)
    let payload = AccessTokenPayload(
      subject: SubjectClaim(value: UUID().uuidString),
      expiration: ExpirationClaim(value: Date().addingTimeInterval(900)),
      issuedAt: IssuedAtClaim(value: Date()),
      role: .user
    )

    let token = try await otherKeys.sign(payload)
    await #expect(throws: (any Error).self) {
      try await keys.verify(token, as: AccessTokenPayload.self)
    }
  }

  @Test("A malformed subject is rejected when resolving the user id")
  func malformedSubject() {
    let payload = AccessTokenPayload(
      subject: SubjectClaim(value: "not-a-uuid"),
      expiration: ExpirationClaim(value: Date().addingTimeInterval(900)),
      issuedAt: IssuedAtClaim(value: Date()),
      role: .user
    )
    #expect(throws: (any Error).self) {
      try payload.userID
    }
  }
}

@Suite("Apple client secret")
struct AppleClientSecretTests {
  @Test("Carries the claims Apple's token endpoint requires, with the kid header")
  func claimsAndHeader() async throws {
    let privateKey = P256.Signing.PrivateKey()
    let kid = JWKIdentifier(string: "TESTKEY123")
    let keys = JWTKeyCollection()
    try await keys.add(ecdsa: ES256PrivateKey(pem: privateKey.pemRepresentation), kid: kid)

    let now = Date()
    let payload = AppleClientSecretPayload(
      issuer: IssuerClaim(value: "TEAMID1234"),
      issuedAt: IssuedAtClaim(value: now),
      expiration: ExpirationClaim(value: now.addingTimeInterval(300)),
      audience: AudienceClaim(value: "https://appleid.apple.com"),
      subject: SubjectClaim(value: "com.cocoaheadsbr.conf")
    )
    let token = try await keys.sign(payload, kid: kid)

    let verified = try await keys.verify(token, as: AppleClientSecretPayload.self)
    #expect(verified.issuer.value == "TEAMID1234")
    #expect(verified.audience.value.contains("https://appleid.apple.com"))
    #expect(verified.subject.value == "com.cocoaheadsbr.conf")

    // Apple requires the key id in the JOSE header.
    let headerSegment = String(token.split(separator: ".")[0])
    var base64 = headerSegment.replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    while base64.count % 4 != 0 { base64.append("=") }
    let headerData = try #require(Data(base64Encoded: base64))
    let header = try #require(
      try JSONSerialization.jsonObject(with: headerData) as? [String: Any]
    )
    #expect(header["kid"] as? String == "TESTKEY123")
    #expect(header["alg"] as? String == "ES256")
  }
}

@Suite("API key middleware")
struct APIKeyMiddlewareTests {
  private func configuration(apiKeys: Set<String>) -> AuthConfiguration {
    AuthConfiguration(
      appleBundleID: "com.cocoaheadsbr.conf",
      apiKeys: apiKeys,
      accessTokenTTL: 900,
      refreshTokenTTL: 3600,
      accountPurgeGraceDays: 30,
      appleTeamID: nil,
      appleSignInKeyID: nil,
      appleSignInPrivateKey: nil
    )
  }

  /// A minimal app with one API-key-gated route — no database needed.
  private func withApp(
    keys: Set<String>,
    _ test: (Application) async throws -> Void
  ) async throws {
    let app = try await Application.make(.testing)
    do {
      app.authConfiguration = configuration(apiKeys: keys)
      app.grouped(APIKeyMiddleware()).get("ping") { _ in "pong" }
      try await test(app)
    } catch {
      try? await app.asyncShutdown()
      throw error
    }
    try await app.asyncShutdown()
  }

  @Test("Accepts a configured key")
  func validKey() async throws {
    try await withApp(keys: ["good-key"]) { app in
      try await app.testing().test(
        .GET, "ping",
        headers: ["X-API-Key": "good-key"],
        afterResponse: { res async in
          #expect(res.status == .ok)
          #expect(res.body.string == "pong")
        }
      )
    }
  }

  @Test("Rejects a missing key")
  func missingKey() async throws {
    try await withApp(keys: ["good-key"]) { app in
      try await app.testing().test(
        .GET, "ping",
        afterResponse: { res async in
          #expect(res.status == .unauthorized)
        }
      )
    }
  }

  @Test("Rejects a wrong key")
  func wrongKey() async throws {
    try await withApp(keys: ["good-key"]) { app in
      try await app.testing().test(
        .GET, "ping",
        headers: ["X-API-Key": "bad-key"],
        afterResponse: { res async in
          #expect(res.status == .unauthorized)
        }
      )
    }
  }

  @Test("Fails closed when no keys are configured")
  func noKeysConfigured() async throws {
    try await withApp(keys: []) { app in
      try await app.testing().test(
        .GET, "ping",
        headers: ["X-API-Key": "any-key"],
        afterResponse: { res async in
          #expect(res.status == .serviceUnavailable)
        }
      )
    }
  }
}
