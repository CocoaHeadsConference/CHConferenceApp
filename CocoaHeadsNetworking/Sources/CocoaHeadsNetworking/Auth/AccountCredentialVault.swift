import Foundation
import Security

/// Implementations must support concurrent callers. Values never belong in the screen cache.
public protocol AccountCredentialVault: Sendable {
  func read(key: String) throws -> Data?
  func write(_ data: Data, key: String) throws
  func remove(key: String) throws
}

public struct KeychainAccountVault: AccountCredentialVault {
  private let service: String

  public init(service: String = "com.cocoaheadsbr.conf.account") {
    self.service = service
  }

  public func read(key: String) throws -> Data? {
    var query = query(key: key)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecItemNotFound { return nil }
    guard status == errSecSuccess, let data = result as? Data else {
      throw AccountError.secureStorage
    }
    return data
  }

  public func write(_ data: Data, key: String) throws {
    let query = query(key: key)
    let update = [kSecValueData as String: data]
    let status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
    if status == errSecItemNotFound {
      var item = query
      item[kSecValueData as String] = data
      item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
      guard SecItemAdd(item as CFDictionary, nil) == errSecSuccess else {
        throw AccountError.secureStorage
      }
    } else if status != errSecSuccess {
      throw AccountError.secureStorage
    }
  }

  public func remove(key: String) throws {
    let status = SecItemDelete(query(key: key) as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw AccountError.secureStorage
    }
  }

  private func query(key: String) -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key,
      kSecAttrSynchronizable as String: false
    ]
  }
}
