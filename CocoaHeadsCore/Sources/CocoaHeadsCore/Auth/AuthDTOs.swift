//
//  AuthDTOs.swift
//
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import Foundation

/// Body of `POST /auth/apple`. Sent by the iOS client after a successful
/// `ASAuthorizationController` run.
public struct AppleSignInRequest: Codable, Equatable, Sendable {
  public init(
    identityToken: String,
    authorizationCode: String,
    fullName: String? = nil,
    email: String? = nil,
    nonce: String? = nil
  ) {
    self.identityToken = identityToken
    self.authorizationCode = authorizationCode
    self.fullName = fullName
    self.email = email
    self.nonce = nonce
  }

  /// The Apple identity token (a JWT) from `ASAuthorizationAppleIDCredential`.
  public let identityToken: String
  /// The single-use authorization code, exchanged server-side for Apple tokens.
  public let authorizationCode: String
  /// Only present on the user's first authorization.
  public let fullName: String?
  /// Only present on the user's first authorization. May be a Hide-My-Email relay.
  public let email: String?
  /// Raw, cryptographically random nonce. The Apple request carries its SHA-256 digest.
  public let nonce: String?
}

/// Token pair returned by `POST /auth/apple` and `POST /auth/refresh`.
public struct TokenResponse: Codable, Equatable, Sendable {
  public init(
    accessToken: String,
    refreshToken: String,
    expiresIn: Int,
    user: UserDTO
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.expiresIn = expiresIn
    self.user = user
  }

  /// Backend-signed JWT. Send as `Authorization: Bearer <token>`.
  public let accessToken: String
  /// Opaque single-use refresh token. Store in the Keychain.
  public let refreshToken: String
  /// Access-token lifetime in seconds.
  public let expiresIn: Int
  public let user: UserDTO
}

/// Body of `POST /auth/refresh` and `POST /auth/logout`.
public struct RefreshRequest: Codable, Equatable, Sendable {
  public init(refreshToken: String) {
    self.refreshToken = refreshToken
  }

  public let refreshToken: String
}

/// The current user, as returned by `GET /me`.
public struct UserDTO: Codable, Equatable, Sendable {
  public init(
    id: UUID,
    email: String? = nil,
    fullName: String? = nil,
    role: UserRole
  ) {
    self.id = id
    self.email = email
    self.fullName = fullName
    self.role = role
  }

  public let id: UUID
  public let email: String?
  public let fullName: String?
  public let role: UserRole
}

/// Global account role. Privileged operations recheck the current database role
/// and chapter assignments; token claims alone never grant publishing access.
public enum UserRole: String, Codable, Equatable, Sendable, CaseIterable {
  case user
  case organizer
  case admin
}
