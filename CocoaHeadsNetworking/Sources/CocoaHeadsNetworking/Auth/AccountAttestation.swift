import DeviceCheck
import Foundation

/// The device-specific operations are injectable so tests never contact Apple.
public protocol AccountAttestation: Sendable {
  var isSupported: Bool { get }
  func generateKey() async throws -> String
  func attestKey(_ keyID: String, clientDataHash: Data) async throws -> Data
  func generateAssertion(_ keyID: String, clientDataHash: Data) async throws -> Data
}

public enum AccountAttestationError: Error, Sendable {
  case invalidKey
  case unavailable
}

public struct DeviceAccountAttestation: AccountAttestation {
  public init() {}

  public var isSupported: Bool { DCAppAttestService.shared.isSupported }

  public func generateKey() async throws -> String {
    do {
      return try await DCAppAttestService.shared.generateKey()
    } catch {
      throw Self.map(error)
    }
  }

  public func attestKey(_ keyID: String, clientDataHash: Data) async throws -> Data {
    do {
      return try await DCAppAttestService.shared.attestKey(keyID, clientDataHash: clientDataHash)
    } catch {
      throw Self.map(error)
    }
  }

  public func generateAssertion(_ keyID: String, clientDataHash: Data) async throws -> Data {
    do {
      return try await DCAppAttestService.shared.generateAssertion(keyID, clientDataHash: clientDataHash)
    } catch {
      throw Self.map(error)
    }
  }

  private static func map(_ error: any Error) -> AccountAttestationError {
    if let error = error as? DCError, error.code == .invalidKey { return .invalidKey }
    return .unavailable
  }
}
