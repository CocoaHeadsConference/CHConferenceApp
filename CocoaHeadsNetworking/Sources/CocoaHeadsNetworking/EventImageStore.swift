import Foundation

/// Media uses its own persistent cache, sharing the catalog's environment/server namespace.
public actor EventImageStore {
  private let configuration: EventClientConfiguration
  private let transport: any EventHTTPTransport
  private var cache: PersistentCache

  public init(
    configuration: EventClientConfiguration,
    transport: any EventHTTPTransport = URLSessionEventTransport(), cacheDirectory: URL? = nil
  ) {
    self.configuration = configuration
    self.transport = transport
    cache = PersistentCache(configuration: configuration, category: "images", directory: cacheDirectory)
  }

  public func data(for url: URL) async throws -> Data {
    try Task.checkCancellation()
    if let entry = cache.read(key: url.absoluteString), !entry.data.isEmpty { return entry.data }
    if configuration.environment == .mock {
      // Only known fixture URLs resolve locally; arbitrary URLs never reach HTTP in Mock.
      guard url == CatalogFixtures.heroImageURL,
        let resource = Bundle.module.url(forResource: "community-hero", withExtension: "png")
      else { throw URLError(.resourceUnavailable) }
      let data = try Data(contentsOf: resource)
      try Task.checkCancellation()
      cache.write(data, key: url.absoluteString, at: .now)
      return data
    }
    guard isWebURL(url) else { throw ScreenLoadingError.invalidResponse }
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
    request.setValue("image/*", forHTTPHeaderField: "Accept")
    let response = try await transport.data(for: request)
    try Task.checkCancellation()
    guard (200...299).contains(response.statusCode) else {
      throw ScreenLoadingError.httpStatus(response.statusCode)
    }
    guard !response.data.isEmpty,
      response.contentType.map({ $0.lowercased().hasPrefix("image/") }) ?? true
    else { throw ScreenLoadingError.invalidResponse }
    cache.write(response.data, key: url.absoluteString, at: .now)
    return response.data
  }
}
