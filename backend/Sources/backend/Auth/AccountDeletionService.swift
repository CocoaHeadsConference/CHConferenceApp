//
//  AccountDeletionService.swift
//  backend
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import Fluent
import Vapor

/// Account deletion per spec §8: soft-delete with immediate PII scrub, token
/// and device-key revocation, and Apple grant revocation. Hard purge happens
/// later via `AccountPurgeService`.
struct AccountDeletionService: Sendable {
  let appleAuth: any AppleAuthServiceProtocol

  func delete(_ user: User, on req: Request) async throws {
    let userID = try user.requireID()

    // Revoke Apple's grant (server-to-server, required for Sign in with
    // Apple). Best-effort: a transient Apple failure must not leave the user
    // unable to delete their account.
    if let encrypted = user.appleRefreshToken {
      do {
        let appleRefreshToken = try req.application.tokenEncryption.decrypt(encrypted)
        try await appleAuth.revokeRefreshToken(appleRefreshToken, on: req)
      } catch {
        req.logger.error("Apple grant revocation failed for user \(userID): \(error)")
      }
    }

    // Scrub PII immediately — the tombstoned row keeps no personal data.
    user.email = nil
    user.fullName = nil
    user.appleRefreshToken = nil
    try await user.save(on: req.db)

    try await TokenService().revokeAll(for: userID, on: req.db)

    // Sets `deleted_at` (Fluent soft delete); hard purge follows after the
    // configured grace period.
    try await user.delete(on: req.db)
  }
}
