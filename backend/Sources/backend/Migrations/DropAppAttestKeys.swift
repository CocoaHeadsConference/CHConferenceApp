import Fluent
import SQLKit

// App Attest was removed. These migrations keep databases migrated before the
// removal upgradable and revertible. They use the literal table name because the
// AppAttestKey model no longer exists.
private let appAttestKeysTable = "app_attest_keys"

/// Retired. Fluent only reverts registered migrations, so databases that recorded
/// this migration need it registered under the same name to revert past its batch.
/// Fresh databases never create the table.
struct CreateAppAttestKey: AsyncMigration {
  func prepare(on database: any Database) async throws {}

  func revert(on database: any Database) async throws {
    try await dropAppAttestKeysIfPresent(on: database)
  }
}

/// Removes the table from databases migrated before the removal. Its foreign key to
/// `users` would otherwise block reverting the auth tables.
struct DropAppAttestKeys: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await dropAppAttestKeysIfPresent(on: database)
  }

  // The table is not recreated: nothing reads it anymore.
  func revert(on database: any Database) async throws {}
}

private func dropAppAttestKeysIfPresent(on database: any Database) async throws {
  guard let sql = database as? any SQLDatabase else { return }
  try await sql.drop(table: appAttestKeysTable).ifExists().run()
}
