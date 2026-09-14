//
//  AppAttestMiddleware.swift
//  backend
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import Crypto
import Fluent
import Foundation
import SQLKit
import Vapor

/// Second gate of the app-authentication layer: verifies a per-request App
/// Attest assertion made with a previously registered key (§6).
///
/// Protocol: the client fetches a one-time challenge (`POST /attest/challenge`)
/// and sends each protected request with:
/// - `X-Attest-Key-Id`: the registered key id (base64)
/// - `X-Attest-Challenge`: the challenge (base64)
/// - `X-Attest-Assertion`: base64 CBOR from
///   `DCAppAttestService.generateAssertion(_:clientDataHash:)`, where
///   `clientDataHash = SHA256(challenge bytes + request body bytes)`.
///
/// Replay protection: challenges are single-use, and the assertion's sign
/// counter must be strictly increasing.
struct AppAttestMiddleware: AsyncMiddleware {
  enum Requirement: Sendable {
    case required
    /// Identity-protected routes also support platforms without App Attest.
    /// Supplying any attestation headers always opts into full verification.
    case whenPresent
  }

  let requirement: Requirement

  init(requirement: Requirement = .required) {
    self.requirement = requirement
  }

  static let keyIdHeader = HTTPHeaders.Name("X-Attest-Key-Id")
  static let challengeHeader = HTTPHeaders.Name("X-Attest-Challenge")
  static let assertionHeader = HTTPHeaders.Name("X-Attest-Assertion")

  func respond(
    to request: Request,
    chainingTo next: any AsyncResponder
  ) async throws -> Response {
    let config = request.authConfiguration
    let hasAttestationHeaders = [Self.keyIdHeader, Self.challengeHeader, Self.assertionHeader]
      .contains { request.headers.contains(name: $0) }

    // A production configuration error cannot silently turn off any verifier.
    if config.appAttestDisabled && request.application.environment == .production {
      throw Abort(.serviceUnavailable, reason: "App Attest cannot be disabled in production.")
    }
    if requirement == .whenPresent && !hasAttestationHeaders {
      return try await next.respond(to: request)
    }
    if config.appAttestDisabled && !hasAttestationHeaders {
      request.logger.warning("App Attest verification is DISABLED (APP_ATTEST_DISABLED).")
      return try await next.respond(to: request)
    }

    guard
      let keyId = request.headers.first(name: Self.keyIdHeader), !keyId.isEmpty,
      let challengeB64 = request.headers.first(name: Self.challengeHeader),
      let assertionB64 = request.headers.first(name: Self.assertionHeader),
      let challenge = Data(base64Encoded: challengeB64), !challenge.isEmpty,
      let assertion = Data(base64Encoded: assertionB64), !assertion.isEmpty
    else {
      throw Abort(.unauthorized, reason: "Missing or invalid App Attest assertion headers.")
    }
    guard let appID = config.appAttestAppID else {
      request.logger.error("APP_ATTEST_TEAM_ID/APPLE_TEAM_ID is not configured.")
      throw Abort(.serviceUnavailable, reason: "App Attest is not configured.")
    }

    guard await request.application.challengeStore.consume(challenge) else {
      throw Abort(.unauthorized, reason: "Unknown or expired App Attest challenge.")
    }

    guard
      let key = try await AppAttestKey.query(on: request.db)
        .filter(\.$keyId == keyId)
        .first(),
      !key.revoked
    else {
      throw Abort(.unauthorized, reason: "Unknown App Attest key.")
    }

    // Respect the application's body-size limit — `max: nil` would buffer
    // arbitrarily large request bodies.
    let maxBodySize = request.application.routes.defaultMaxBodySize.value
    let collected = try await request.body.collect(max: maxBodySize).get()
    let body = collected.map { Data(buffer: $0) } ?? Data()
    let clientDataHash = Data(SHA256.hash(data: challenge + body))

    let verifier = AppAttestVerifier(environment: config.appAttestEnvironment)
    let newSignCount: Int
    do {
      newSignCount = try verifier.verifyAssertion(
        assertion,
        publicKey: key.publicKey,
        clientDataHash: clientDataHash,
        appID: appID,
        storedSignCount: key.signCount
      )
    } catch {
      request.logger.info("App Attest assertion rejected: \(error)")
      throw Abort(.unauthorized, reason: "Invalid App Attest assertion.")
    }
    // Conditional update so a concurrent assertion cannot move the counter
    // backwards: only persist when the stored count is still lower.
    guard try await Self.claimAssertion(keyID: key.requireID(), signCount: newSignCount, on: request.db) else {
      throw Abort(.unauthorized, reason: "App Attest assertion was already used or its key was revoked.")
    }

    request.storage[AttestedKeyIDKey.self] = keyId
    return try await next.respond(to: request)
  }

  static func claimAssertion(keyID: UUID, signCount: Int, on db: any Database) async throws -> Bool {
    guard let sql = db as? any SQLDatabase else {
      throw Abort(.internalServerError, reason: "App Attest requires an atomic SQL counter update.")
    }
    let claimed = try await sql.raw(
      """
      UPDATE \(ident: AppAttestKey.schema)
      SET sign_count = \(bind: signCount)
      WHERE id = \(bind: keyID) AND sign_count < \(bind: signCount) AND revoked = false
      RETURNING id
      """
    ).all()
    return !claimed.isEmpty
  }
}

/// Request-storage key carrying the verified App Attest key id, so sign-in can
/// associate the device key with the user.
struct AttestedKeyIDKey: StorageKey {
  typealias Value = String
}

extension Request {
  var attestedKeyID: String? { storage[AttestedKeyIDKey.self] }
}
