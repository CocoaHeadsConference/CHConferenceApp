//
//  TokenEncryption.swift
//  backend
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import Crypto
import Foundation
import Vapor

/// AES-256-GCM encryption for secrets at rest (the stored Apple refresh token).
///
/// The key comes from `TOKEN_ENCRYPTION_KEY` (base64, 32 bytes). When unset, a
/// key is derived from `JWT_SIGNING_KEY` so local development works without
/// extra configuration — production should set a dedicated key.
struct TokenEncryption: Sendable {
  private let key: SymmetricKey

  init(key: SymmetricKey) {
    self.key = key
  }

  static func load() throws -> TokenEncryption {
    if let base64 = AuthEnvironment.value("TOKEN_ENCRYPTION_KEY") {
      guard let data = Data(base64Encoded: base64), data.count == 32 else {
        throw AuthError.invalidEncryptionKey
      }
      return TokenEncryption(key: SymmetricKey(data: data))
    }
    guard let signingKey = AuthEnvironment.value("JWT_SIGNING_KEY") else {
      throw AuthError.missingSigningKey
    }
    let derived = SHA256.hash(data: Data("token-encryption:\(signingKey)".utf8))
    return TokenEncryption(key: SymmetricKey(data: Data(derived)))
  }

  /// Returns base64(nonce + ciphertext + tag).
  func encrypt(_ plaintext: String) throws -> String {
    let sealed = try AES.GCM.seal(Data(plaintext.utf8), using: key)
    guard let combined = sealed.combined else {
      throw AuthError.encryptionFailed
    }
    return combined.base64EncodedString()
  }

  func decrypt(_ base64: String) throws -> String {
    guard let combined = Data(base64Encoded: base64) else {
      throw AuthError.encryptionFailed
    }
    let box = try AES.GCM.SealedBox(combined: combined)
    let plaintext = try AES.GCM.open(box, using: key)
    guard let string = String(data: plaintext, encoding: .utf8) else {
      throw AuthError.encryptionFailed
    }
    return string
  }
}

enum AuthError: Error {
  case missingSigningKey
  case invalidEncryptionKey
  case encryptionFailed
}

extension Application {
  private struct TokenEncryptionKey: StorageKey {
    typealias Value = TokenEncryption
  }

  var tokenEncryption: TokenEncryption {
    get {
      guard let encryption = storage[TokenEncryptionKey.self] else {
        fatalError("TokenEncryption not set. Call configure(_:) first.")
      }
      return encryption
    }
    set { storage[TokenEncryptionKey.self] = newValue }
  }
}
