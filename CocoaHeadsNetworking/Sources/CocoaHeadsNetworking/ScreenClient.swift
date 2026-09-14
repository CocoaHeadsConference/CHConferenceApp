import CocoaHeadsCore
import Foundation

struct LoadedScreen<Content: Sendable>: Sendable {
  let content: Content
  let data: Data
}

protocol ScreenClient: Sendable {
  func send<R: ScreenRequest>(_ request: R) async throws -> LoadedScreen<R.Content>
}

struct LiveScreenClient: ScreenClient {
  let configuration: EventClientConfiguration
  let transport: any EventHTTPTransport

  func send<R: ScreenRequest>(_ request: R) async throws -> LoadedScreen<R.Content> {
    try Task.checkCancellation()
    let url = try makeURL(for: request)
    var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    let response = try await transport.data(for: urlRequest)
    try Task.checkCancellation()
    guard (200...299).contains(response.statusCode) else {
      throw ScreenLoadingError.httpStatus(response.statusCode)
    }
    let content = try ScreenCodec.decode(response.data, for: request)
    return LoadedScreen(content: content, data: response.data)
  }

  private func makeURL<R: ScreenRequest>(for request: R) throws -> URL {
    guard let baseURL = configuration.baseURL, isWebURL(baseURL),
      var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false),
      components.query == nil, components.fragment == nil,
      components.user == nil, components.password == nil
    else { throw ScreenLoadingError.missingServerConfiguration }
    let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_~")
    let encoded = try request.pathComponents.map { component in
      guard !component.isEmpty, let encoded = component.addingPercentEncoding(withAllowedCharacters: allowed)
      else { throw ScreenLoadingError.invalidResponse }
      return encoded
    }
    let prefix =
      components.percentEncodedPath.hasSuffix("/")
      ? String(components.percentEncodedPath.dropLast()) : components.percentEncodedPath
    components.percentEncodedPath = prefix + "/" + encoded.joined(separator: "/")
    guard let url = components.url else { throw ScreenLoadingError.missingServerConfiguration }
    return url
  }
}

struct MockScreenClient: ScreenClient {
  let scenario: MockScenario
  let now: @Sendable () -> Date
  let delay: Duration
  var organizerStore: MockOrganizerStore? = nil

  func send<R: ScreenRequest>(_ request: R) async throws -> LoadedScreen<R.Content> {
    try Task.checkCancellation()
    try await Task.sleep(for: delay)
    let data: Data
    switch scenario {
    case .standard, .empty:
      let fixtures: EventCatalog
      if let organizerStore {
        fixtures = await organizerStore.catalog()
      } else {
        fixtures = CatalogFixtures.catalog(now: now())
      }
      let catalog = scenario == .empty ? EventCatalog(chapters: fixtures.chapters, events: []) : fixtures
      data = try ScreenCodec.encode(request.mockContent(from: catalog), for: request)
    case .offline:
      throw URLError(.notConnectedToInternet)
    case .serverError:
      throw ScreenLoadingError.httpStatus(503)
    case .unsupported:
      data = Data(#"{"schemaVersion":2,"screen":"futureScreen","content":{}}"#.utf8)
    case .malformed:
      data = try JSONSerialization.data(withJSONObject: [
        "schemaVersion": CatalogScreen.version, "screen": request.screen, "content": NSNull()
      ])
    }
    let content = try ScreenCodec.decode(data, for: request)
    return LoadedScreen(content: content, data: data)
  }
}
