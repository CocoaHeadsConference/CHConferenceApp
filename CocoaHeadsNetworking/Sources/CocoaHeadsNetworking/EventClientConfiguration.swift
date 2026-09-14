import Foundation

public enum CatalogEnvironment: String, Sendable {
  case production, localhost, mock
}

public enum MockScenario: String, CaseIterable, Sendable {
  case standard, empty, offline, serverError, unsupported, malformed
}

public struct EventClientConfiguration: Sendable {
  public let environment: CatalogEnvironment
  public let baseURL: URL?
  public let scenario: MockScenario

  public init(
    environment: CatalogEnvironment, baseURL: URL? = nil,
    scenario: MockScenario = .standard
  ) {
    self.environment = environment
    self.baseURL = baseURL
    self.scenario = scenario
  }

  var cacheNamespace: String {
    // Scenarios share the mock namespace so Offline can exercise a previously viewed screen.
    let server = environment == .mock ? "fixtures" : baseURL?.absoluteString ?? "unconfigured"
    return "\(environment.rawValue)/\(server)"
  }
}

public struct ScreenSnapshot<Value: Sendable>: Sendable {
  public let content: Value
  public let cachedAt: Date
  public let isStale: Bool

  public init(content: Value, cachedAt: Date, isStale: Bool) {
    self.content = content
    self.cachedAt = cachedAt
    self.isStale = isStale
  }
}

/// Transport failures remain URLError (or the injected transport's error).
public enum ScreenLoadingError: Error, Equatable, Sendable {
  case unsupportedScreen
  case invalidResponse
  case httpStatus(Int)
  case missingServerConfiguration
}
