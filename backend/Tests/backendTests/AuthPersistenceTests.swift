import Fluent
import FluentPostgresDriver
import Foundation
import Testing
import VaporTesting

@testable import backend

/// Requires an explicitly named disposable database ending in `_test`.
/// `TEST_DATABASE_NAME=cocoaheads_auth_test swift test --filter AuthPersistenceTests`
@Suite(
  "Authentication persistence (Postgres)", .serialized,
  .enabled(if: Environment.get("TEST_DATABASE_NAME")?.hasSuffix("_test") == true)
)
struct AuthPersistenceTests {
  private func withDatabase(_ test: (any Database) async throws -> Void) async throws {
    let name = try #require(Environment.get("TEST_DATABASE_NAME"))
    #expect(name.hasSuffix("_test"))
    let app = try await Application.make(.testing)
    do {
      app.databases.use(
        .postgres(
          configuration: .init(
            hostname: Environment.get("TEST_DATABASE_HOST") ?? "localhost",
            port: Environment.get("TEST_DATABASE_PORT").flatMap(Int.init) ?? 5432,
            username: Environment.get("TEST_DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("TEST_DATABASE_PASSWORD") ?? "vapor_password",
            database: name, tls: .disable)), as: .psql)
      app.migrations.add(CreateUser())
      app.migrations.add(CreateRefreshToken())
      try await app.autoMigrate()
      try await test(app.db)
      try await app.autoRevert()
    } catch {
      try? await app.autoRevert()
      try? await app.asyncShutdown()
      throw error
    }
    try await app.asyncShutdown()
  }

  @Test("Signing in after deletion creates a different ordinary account")
  func deletedAccountDoesNotRegainPermissions() async throws {
    try await withDatabase { db in
      let old = User(appleUserIdentifier: "same-apple-subject", role: .admin)
      try await old.save(on: db)
      let oldID = try old.requireID()
      try await old.delete(on: db)

      let fresh = try await AppleUserService().signIn(
        appleIdentifier: "same-apple-subject", email: "new@example.com", fullName: "New Account",
        encryptedRefreshToken: "new-grant", on: db)
      #expect(try fresh.requireID() != oldID)
      #expect(fresh.role == .user)
      #expect(fresh.deletedAt == nil)
      #expect(fresh.appleRefreshToken == "new-grant")
      let tombstone = try #require(try await User.query(on: db).withDeleted().filter(\.$id == oldID).first())
      #expect(tombstone.deletedAt != nil)
      #expect(tombstone.appleUserIdentifier != "same-apple-subject")
    }
  }

  @Test("An existing active organizer keeps their server-managed permissions")
  func existingAccount() async throws {
    try await withDatabase { db in
      let original = User(appleUserIdentifier: "active-user", role: .organizer, appleRefreshToken: "saved-grant")
      try await original.save(on: db)
      let returned = try await AppleUserService().signIn(
        appleIdentifier: "active-user", email: nil, fullName: "Updated Name", encryptedRefreshToken: nil, on: db)
      #expect(returned.id == original.id)
      #expect(returned.role == .organizer)
      #expect(returned.fullName == "Updated Name")
      #expect(returned.appleRefreshToken == "saved-grant")
    }
  }

  @Test("Concurrent account recreation converges on one new ordinary user")
  func concurrentRecreation() async throws {
    try await withDatabase { db in
      let old = User(appleUserIdentifier: "concurrent-user", role: .admin)
      try await old.save(on: db)
      try await old.delete(on: db)
      async let first = AppleUserService().signIn(
        appleIdentifier: "concurrent-user", email: nil, fullName: nil, encryptedRefreshToken: nil, on: db)
      async let second = AppleUserService().signIn(
        appleIdentifier: "concurrent-user", email: nil, fullName: nil, encryptedRefreshToken: nil, on: db)
      let (a, b) = try await (first, second)
      #expect(a.id == b.id)
      #expect(a.id != old.id)
      #expect(a.role == .user)
      #expect(b.role == .user)
    }
  }
}
