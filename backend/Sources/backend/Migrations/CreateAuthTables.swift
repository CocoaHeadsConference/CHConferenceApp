//
//  CreateAuthTables.swift
//  backend
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import Fluent

struct CreateUser: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(User.schema)
      .id()
      .field("apple_user_identifier", .string, .required)
      .field("email", .string)
      .field("full_name", .string)
      .field("role", .string, .required)
      .field("apple_refresh_token", .string)
      .field("deleted_at", .datetime)
      .field("created_at", .datetime)
      .field("updated_at", .datetime)
      .unique(on: "apple_user_identifier")
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(User.schema).delete()
  }
}

struct CreateRefreshToken: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(RefreshToken.schema)
      .id()
      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
      .field("token_hash", .string, .required)
      .field("expires_at", .datetime, .required)
      .field("revoked", .bool, .required, .sql(.default(false)))
      .field("created_at", .datetime)
      .unique(on: "token_hash")
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(RefreshToken.schema).delete()
  }
}
