import CocoaHeadsCore
import Fluent
import Foundation
import NIOConcurrencyHelpers
import Testing
import VaporTesting

@testable import backend

/// DB-backed rotation tests. Requires TEST_DATABASE and an explicit DATABASE_NAME
/// ending in `_test`. This suite creates/reverts all configured migrations, so use
/// a disposable database and run separately from OrganizerIntegrationTests.
/// See docs/organizer-setup.md for the complete connection environment.
@Suite(
  "Refresh token rotation (Postgres)",
  .serialized,
  .enabled(if: Environment.get("TEST_DATABASE") != nil)
)
struct RotationIntegrationTests {
  private func withApp(_ test: (Application) async throws -> Void) async throws {
    // This check must run before app creation/configuration and outside cleanup:
    // autoRevert drops every migrated table in the selected database.
    let databaseName = try #require(
      Environment.get("DATABASE_NAME"), "Set DATABASE_NAME explicitly to a disposable database ending in _test.")
    try #require(
      databaseName.hasSuffix("_test"), "Refusing destructive tests against a database without the _test suffix.")
    let app = try await Application.make(.testing)
    do {
      try await configure(app)
      // configure(_:) read auth settings from the process environment; force
      // the values these tests need.
      app.authConfiguration = AuthConfiguration(
        appleBundleID: "com.cocoaheadsbr.conf",
        apiKeys: ["test-key"],
        accessTokenTTL: 900,
        refreshTokenTTL: 3600,
        accountPurgeGraceDays: 30,
        appleTeamID: nil,
        appleSignInKeyID: nil,
        appleSignInPrivateKey: nil,
        appAttestTeamID: nil,
        appAttestEnvironment: .production,
        appAttestDisabled: true
      )
      try await app.autoMigrate()
      try await test(app)
      try await app.autoRevert()
    } catch {
      try? await app.autoRevert()
      try? await app.asyncShutdown()
      throw error
    }
    try await app.asyncShutdown()
  }

  private func makeUser(on db: any Database) async throws -> User {
    let user = User(appleUserIdentifier: "rotation-test-\(UUID().uuidString)")
    try await user.save(on: db)
    return user
  }

  private func storeRefreshToken(for user: User, on db: any Database) async throws -> String {
    let raw = TokenService.generateRefreshToken()
    try await RefreshToken(
      userID: try user.requireID(),
      tokenHash: TokenService.hash(raw),
      expiresAt: Date().addingTimeInterval(3600)
    ).save(on: db)
    return raw
  }

  private func refresh(
    _ app: Application,
    token: String,
    afterResponse: @escaping @Sendable (TestingHTTPResponse) async throws -> Void
  ) async throws {
    try await app.testing().test(
      .POST, "auth/refresh",
      headers: ["X-API-Key": "test-key"],
      beforeRequest: { req in
        try req.content.encode(RefreshRequest(refreshToken: token))
      },
      afterResponse: afterResponse
    )
  }

  @Test("Rotation issues a new pair and revokes the presented token")
  func successfulRotation() async throws {
    try await withApp { app in
      let user = try await makeUser(on: app.db)
      let raw = try await storeRefreshToken(for: user, on: app.db)

      try await refresh(app, token: raw) { res in
        #expect(res.status == .ok)
        let pair = try res.content.decode(TokenResponse.self)
        #expect(pair.user.id == user.id)
        #expect(pair.refreshToken != raw)
      }

      let original = try await RefreshToken.query(on: app.db)
        .filter(\.$tokenHash == TokenService.hash(raw))
        .first()
      #expect(original?.revoked == true)
    }
  }

  @Test("Reusing a rotated token revokes the entire token family")
  func reuseRevokesFamily() async throws {
    try await withApp { app in
      let user = try await makeUser(on: app.db)
      let rawA = try await storeRefreshToken(for: user, on: app.db)

      let rawB = NIOLockedValueBox<String?>(nil)
      try await refresh(app, token: rawA) { res in
        #expect(res.status == .ok)
        let refreshToken = try res.content.decode(TokenResponse.self).refreshToken
        rawB.withLockedValue { $0 = refreshToken }
      }
      let successor = try #require(rawB.withLockedValue { $0 })

      // Presenting the consumed token again is treated as theft…
      try await refresh(app, token: rawA) { res in
        #expect(res.status == .unauthorized)
      }

      // …so every token of the user is revoked, including the successor.
      let survivors = try await RefreshToken.query(on: app.db)
        .filter(\.$user.$id == user.requireID())
        .filter(\.$revoked == false)
        .count()
      #expect(survivors == 0)

      try await refresh(app, token: successor) { res in
        #expect(res.status == .unauthorized)
      }
    }
  }

  @Test("Expired tokens are rejected and swept by the purge job")
  func expiredToken() async throws {
    try await withApp { app in
      let user = try await makeUser(on: app.db)
      let raw = TokenService.generateRefreshToken()
      try await RefreshToken(
        userID: try user.requireID(),
        tokenHash: TokenService.hash(raw),
        expiresAt: Date().addingTimeInterval(-60)
      ).save(on: app.db)

      try await refresh(app, token: raw) { res in
        #expect(res.status == .unauthorized)
      }

      await AccountPurgeService.purge(on: app)
      let remaining = try await RefreshToken.query(on: app.db)
        .filter(\.$tokenHash == TokenService.hash(raw))
        .count()
      #expect(remaining == 0)
    }
  }
}
