import Crypto
import Foundation
import Testing

@testable import backend

@Suite("Token service")
struct TokenServiceTests {
  @Test("Refresh tokens are unique and URL-safe")
  func refreshTokenGeneration() {
    let a = TokenService.generateRefreshToken()
    let b = TokenService.generateRefreshToken()
    #expect(a != b)
    #expect(!a.contains("+") && !a.contains("/") && !a.contains("="))
  }

  @Test("Hashing is stable and hides the token")
  func hashing() {
    let token = "some-refresh-token"
    let hash = TokenService.hash(token)
    #expect(hash == TokenService.hash(token))
    #expect(hash != TokenService.hash("other-token"))
    #expect(hash.count == 64)
    #expect(!hash.contains(token))
  }
}

@Suite("Token encryption")
struct TokenEncryptionTests {
  @Test("Round-trips and never stores plaintext")
  func roundTrip() throws {
    let encryption = TokenEncryption(key: SymmetricKey(size: .bits256))
    let secret = "apple-refresh-token-value"
    let encrypted = try encryption.encrypt(secret)
    #expect(!encrypted.contains(secret))
    #expect(try encryption.decrypt(encrypted) == secret)
  }

  @Test("Distinct keys cannot decrypt each other's output")
  func wrongKey() throws {
    let a = TokenEncryption(key: SymmetricKey(size: .bits256))
    let b = TokenEncryption(key: SymmetricKey(size: .bits256))
    let encrypted = try a.encrypt("secret")
    #expect(throws: (any Error).self) {
      try b.decrypt(encrypted)
    }
  }
}
