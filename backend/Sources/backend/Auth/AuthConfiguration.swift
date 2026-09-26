//
//  AuthConfiguration.swift
//  backend
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import Vapor

/// Auth-related environment configuration, loaded once in `configure(_:)`.
///
/// Environment variables (see also `DATABASE_*` and `FIRECRAWL_API_KEY`):
/// - `JWT_SIGNING_KEY`: ES256 private key PEM (recommended) or an HS256 secret.
/// - `APPLE_BUNDLE_ID`: expected `aud` of the Apple identity token / client id.
/// - `API_KEYS`: comma-separated static client keys for the coarse API-key gate.
/// - `ACCESS_TOKEN_TTL`: access-token lifetime in seconds (default 900).
/// - `REFRESH_TOKEN_TTL`: refresh-token lifetime in seconds (default 45 days).
/// - `ACCOUNT_PURGE_GRACE_DAYS`: hard-purge delay after soft-delete (default 30).
/// - `APPLE_TEAM_ID`, `APPLE_SIGNIN_KEY_ID`, `APPLE_SIGNIN_PRIVATE_KEY`:
///   Sign in with Apple service credentials (client-secret JWT for Apple's
///   token & revoke endpoints).
/// - `TOKEN_ENCRYPTION_KEY`: base64 32-byte AES-256 key for encrypting the
///   stored Apple refresh token. Falls back to a key derived from
///   `JWT_SIGNING_KEY` when unset.
struct AuthConfiguration: Sendable {
  let appleBundleID: String
  let apiKeys: Set<String>
  let accessTokenTTL: TimeInterval
  let refreshTokenTTL: TimeInterval
  let accountPurgeGraceDays: Int
  let appleTeamID: String?
  let appleSignInKeyID: String?
  let appleSignInPrivateKey: String?

  /// Whether the Sign in with Apple `.p8` service credentials are configured
  /// (required for the authorization-code exchange and grant revocation).
  var hasAppleServiceCredentials: Bool {
    appleTeamID != nil && appleSignInKeyID != nil && appleSignInPrivateKey != nil
  }

  static func load(from environment: Environment) -> AuthConfiguration {
    AuthConfiguration(
      appleBundleID: Environment.get("APPLE_BUNDLE_ID") ?? "com.cocoaheadsbr.conf",
      apiKeys: Set(
        (Environment.get("API_KEYS") ?? "")
          .split(separator: ",")
          .map { $0.trimmingCharacters(in: .whitespaces) }
          .filter { !$0.isEmpty }
      ),
      accessTokenTTL: Environment.get("ACCESS_TOKEN_TTL").flatMap(TimeInterval.init) ?? 900,
      refreshTokenTTL: Environment.get("REFRESH_TOKEN_TTL").flatMap(TimeInterval.init)
        ?? 45 * 24 * 60 * 60,
      accountPurgeGraceDays: Environment.get("ACCOUNT_PURGE_GRACE_DAYS").flatMap(Int.init) ?? 30,
      appleTeamID: Environment.get("APPLE_TEAM_ID"),
      appleSignInKeyID: Environment.get("APPLE_SIGNIN_KEY_ID"),
      appleSignInPrivateKey: Environment.get("APPLE_SIGNIN_PRIVATE_KEY")
    )
  }
}

extension Application {
  private struct AuthConfigurationKey: StorageKey {
    typealias Value = AuthConfiguration
  }

  var authConfiguration: AuthConfiguration {
    get {
      guard let config = storage[AuthConfigurationKey.self] else {
        fatalError("AuthConfiguration not set. Call configure(_:) first.")
      }
      return config
    }
    set { storage[AuthConfigurationKey.self] = newValue }
  }
}

extension Request {
  var authConfiguration: AuthConfiguration { application.authConfiguration }
}
