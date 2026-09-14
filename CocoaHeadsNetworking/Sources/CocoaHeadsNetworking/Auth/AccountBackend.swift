import CocoaHeadsCore
import CryptoKit
import Foundation

/// Used only through AccountClient's operation gate, including complete assertion round trips.
actor AccountBackend {
  private struct AttestedKey: Codable {
    let id: String
    var registered: Bool
  }

  private let configuration: EventClientConfiguration
  private let apiKey: String
  private let transport: any EventHTTPTransport
  private let vault: any AccountCredentialVault
  private let attestation: any AccountAttestation
  private let attestationStorageKey: String
  private var key: AttestedKey?

  init(
    configuration: EventClientConfiguration, apiKey: String,
    transport: any EventHTTPTransport, vault: any AccountCredentialVault,
    attestation: any AccountAttestation, namespace: String
  ) {
    self.configuration = configuration
    self.apiKey = apiKey
    self.transport = transport
    self.vault = vault
    self.attestation = attestation
    attestationStorageKey = namespace + "/attestation"
  }

  static func isConfigured(_ configuration: EventClientConfiguration, apiKey: String) -> Bool {
    configuration.environment == .mock
      || (!apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && (try? url(configuration: configuration, path: [])) != nil)
  }

  static func namespace(_ configuration: EventClientConfiguration) -> String {
    let server = configuration.baseURL?.absoluteString ?? "unconfigured"
    let value = Data("\(configuration.environment.rawValue)/\(server)".utf8)
    let digest = SHA256.hash(data: value).map { String(format: "%02x", $0) }.joined()
    return "account-v1/\(digest)"
  }

  func send(
    path: [String], method: String, body: Data? = nil, bearer: String? = nil,
    beforeSend: (@Sendable () async throws -> Void)? = nil
  ) async throws -> Data {
    guard configuration.environment != .mock else { throw AccountError.mockEndpointUnavailable }
    guard Self.isConfigured(configuration, apiKey: apiKey) else { throw AccountError.notConfigured }
    var request = try request(path: path, method: method, body: body)
    if let bearer { request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization") }
    if Self.requiresAttestation(configuration, isSupported: attestation.isSupported) {
      let headers = try await assertionHeaders(body: body ?? Data())
      for (name, value) in headers { request.setValue(value, forHTTPHeaderField: name) }
    }
    // Mark refresh rotation immediately before handing its bytes to the transport.
    // Challenge/key failures before this point do not consume the stored refresh token.
    try Task.checkCancellation()
    try await beforeSend?()
    do {
      return try await transmit(request)
    } catch let error as AccountError {
      if error.statusCode == 401, error.reason == "Unknown App Attest key." {
        // A restored server may no longer know this device. The user's next explicit
        // attempt can register a fresh key; this request is never replayed automatically.
        try? clearAttestation()
      }
      throw error
    }
  }

  func clearAttestation() throws {
    key = nil
    try vault.remove(key: attestationStorageKey)
  }

  static func requiresAttestation(_ configuration: EventClientConfiguration, isSupported: Bool) -> Bool {
    // Account/organizer routes accept Apple-authenticated sessions on unsupported platforms.
    // On supported devices, attestation errors propagate; they never trigger an unverified retry.
    guard isSupported else { return false }
    #if DEBUG
      if configuration.environment == .localhost { return false }
    #endif
    return true
  }

  private func assertionHeaders(body: Data) async throws -> [String: String] {
    do {
      let keyID = try await registeredKey()
      let challenge = try await challenge()
      let bytes = try Self.challengeBytes(challenge)
      let hash = Data(SHA256.hash(data: bytes + body))
      let assertion = try await attestation.generateAssertion(keyID, clientDataHash: hash)
      return [
        "X-Attest-Key-Id": keyID,
        "X-Attest-Challenge": challenge.challenge,
        "X-Attest-Assertion": assertion.base64EncodedString()
      ]
    } catch AccountAttestationError.invalidKey {
      // Device keys do not survive reinstall/restore even if the Keychain identifier does.
      try clearAttestation()
      throw AccountError.appAttestFailed
    } catch is AccountAttestationError {
      throw AccountError.appAttestFailed
    }
  }

  private func registeredKey() async throws -> String {
    if key == nil, let data = try vault.read(key: attestationStorageKey) {
      guard let stored = try? JSONDecoder().decode(AttestedKey.self, from: data) else {
        throw AccountError.secureStorage
      }
      key = stored
    }
    if let key, key.registered { return key.id }
    let candidate: AttestedKey
    if let key {
      candidate = key
    } else {
      let id = try await attestation.generateKey()
      guard !id.isEmpty else { throw AccountError.appAttestFailed }
      candidate = AttestedKey(id: id, registered: false)
      try saveKey(candidate)
    }
    let challenge = try await challenge()
    let bytes = try Self.challengeBytes(challenge)
    // Keep a generated key on Apple's temporary outage, as Apple recommends.
    let object = try await attestation.attestKey(candidate.id, clientDataHash: Data(SHA256.hash(data: bytes)))
    let body = try JSONEncoder().encode(
      AttestKeyRegistrationRequest(
        keyId: candidate.id, attestation: object.base64EncodedString(), challenge: challenge.challenge))
    do {
      let registration = try request(path: ["attest", "key"], method: "POST", body: body)
      _ = try await transmit(registration)
      try saveKey(AttestedKey(id: candidate.id, registered: true))
    } catch {
      // The one-use challenge may have been consumed; a future attempt must start afresh.
      try? clearAttestation()
      throw error
    }
    return candidate.id
  }

  private func saveKey(_ value: AttestedKey) throws {
    try vault.write(JSONEncoder().encode(value), key: attestationStorageKey)
    key = value
  }

  private func challenge() async throws -> AttestChallengeResponse {
    let request = try request(path: ["attest", "challenge"], method: "POST", body: nil)
    let data = try await transmit(request)
    guard let value = try? JSONDecoder().decode(AttestChallengeResponse.self, from: data), value.expiresIn > 0 else {
      throw AccountError.invalidResponse
    }
    return value
  }

  private static func challengeBytes(_ value: AttestChallengeResponse) throws -> Data {
    guard let bytes = Data(base64Encoded: value.challenge), !bytes.isEmpty else {
      throw AccountError.invalidResponse
    }
    return bytes
  }

  private func request(path: [String], method: String, body: Data?) throws -> URLRequest {
    guard ["GET", "POST", "PUT", "PATCH", "DELETE"].contains(method) else {
      throw AccountError.invalidRequest
    }
    let url = try Self.url(configuration: configuration, path: path)
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
    request.httpMethod = method
    request.httpBody = body
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    if body != nil { request.setValue("application/json", forHTTPHeaderField: "Content-Type") }
    return request
  }

  private func transmit(_ request: URLRequest) async throws -> Data {
    let response = try await transport.data(for: request)
    guard (200...299).contains(response.statusCode) else {
      struct Failure: Decodable { let reason: String? }
      let reason = (try? JSONDecoder().decode(Failure.self, from: response.data))?.reason
      throw AccountError.httpStatus(response.statusCode, reason: reason)
    }
    return response.data
  }

  private static func url(configuration: EventClientConfiguration, path: [String]) throws -> URL {
    guard let baseURL = configuration.baseURL,
      var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false),
      !(components.host ?? "").isEmpty,
      components.query == nil, components.fragment == nil,
      components.user == nil, components.password == nil
    else { throw AccountError.notConfigured }
    let schemes = configuration.environment == .localhost ? ["http", "https"] : ["https"]
    guard schemes.contains(components.scheme?.lowercased() ?? "") else { throw AccountError.notConfigured }
    let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_~")
    let encoded = try path.map { component in
      guard !component.isEmpty, let encoded = component.addingPercentEncoding(withAllowedCharacters: allowed) else {
        throw AccountError.invalidRequest
      }
      return encoded
    }
    let prefix = components.percentEncodedPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    components.percentEncodedPath = "/" + ([prefix].filter { !$0.isEmpty } + encoded).joined(separator: "/")
    guard let url = components.url else { throw AccountError.invalidRequest }
    return url
  }
}
