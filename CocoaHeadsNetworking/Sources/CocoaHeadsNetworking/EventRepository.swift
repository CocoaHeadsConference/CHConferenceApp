import CocoaHeadsCore
import Foundation

public actor EventRepository {
  private let client: any ScreenClient
  private let now: @Sendable () -> Date
  private var cache: PersistentCache

  public init(
    configuration: EventClientConfiguration,
    transport: any EventHTTPTransport = URLSessionEventTransport(),
    cacheDirectory: URL? = nil, now: @escaping @Sendable () -> Date = { .now },
    mockDelay: Duration = .milliseconds(250),
    mockOrganizerStore: MockOrganizerStore? = nil
  ) {
    self.now = now
    cache = PersistentCache(configuration: configuration, category: "screens", directory: cacheDirectory)
    switch configuration.environment {
    case .mock:
      client = MockScreenClient(
        scenario: configuration.scenario,
        now: now, delay: mockDelay, organizerStore: mockOrganizerStore)
    case .production, .localhost:
      client = LiveScreenClient(configuration: configuration, transport: transport)
    }
  }

  public func catalog() async throws -> ScreenSnapshot<EventCatalog> {
    let snapshot = try await load(CatalogRequest())
    if !snapshot.isStale {
      // Feed items carry complete event content, so previously browsed events work offline too.
      for event in snapshot.content.events {
        let request = EventRequest(id: event.id)
        if let data = try? ScreenCodec.encode(event, for: request) {
          cache.write(data, key: request.cacheKey, at: snapshot.cachedAt)
        }
      }
    }
    return snapshot
  }

  public func event(id: String) async throws -> ScreenSnapshot<CommunityEvent> {
    try await load(EventRequest(id: id))
  }

  public func cachedCatalog() async -> ScreenSnapshot<EventCatalog>? {
    cached(CatalogRequest())
  }

  public func cachedEvent(id: String) async -> ScreenSnapshot<CommunityEvent>? {
    cached(EventRequest(id: id))
  }

  private func load<R: ScreenRequest>(_ request: R) async throws -> ScreenSnapshot<R.Content> {
    do {
      try Task.checkCancellation()
      let loaded = try await client.send(request)
      try Task.checkCancellation()
      let date = now()
      cache.write(loaded.data, key: request.cacheKey, at: date)
      return ScreenSnapshot(content: loaded.content, cachedAt: date, isStale: false)
    } catch {
      if Task.isCancelled || isCancellation(error) { throw CancellationError() }
      if error as? ScreenLoadingError == .unsupportedScreen { throw error }
      if let snapshot = cached(request) { return snapshot }
      throw error
    }
  }

  private func cached<R: ScreenRequest>(_ request: R) -> ScreenSnapshot<R.Content>? {
    guard let entry = cache.read(key: request.cacheKey),
      let content = try? ScreenCodec.decode(entry.data, for: request)
    else { return nil }
    return ScreenSnapshot(content: content, cachedAt: entry.cachedAt, isStale: true)
  }
}
