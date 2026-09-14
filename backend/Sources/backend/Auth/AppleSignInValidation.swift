import Crypto
import JWT
import Vapor

enum AppleSignInValidation {
  static func requireNonce(_ rawNonce: String?) throws -> String {
    guard let rawNonce, !rawNonce.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw Abort(.badRequest, reason: "A sign-in nonce is required.")
    }
    return rawNonce
  }

  /// Call only after the identity token's signature, issuer, and expiry are verified.
  static func validate(_ identity: AppleIdentityToken, rawNonce: String, audience: String) throws {
    guard identity.audience.value.contains(audience), !identity.subject.value.isEmpty else {
      throw Abort(.unauthorized, reason: "Apple identity is not intended for this application.")
    }
    let expected = SHA256.hash(data: Data(rawNonce.utf8)).map { String(format: "%02x", $0) }.joined()
    guard identity.nonce == expected else {
      throw Abort(.unauthorized, reason: "Apple identity does not match the sign-in nonce.")
    }
  }

  static func match(_ identity: AppleIdentityToken, exchangedIdentity: AppleIdentityToken) throws {
    guard identity.subject.value == exchangedIdentity.subject.value else {
      throw Abort(.unauthorized, reason: "Apple authorization code belongs to a different identity.")
    }
  }
}
