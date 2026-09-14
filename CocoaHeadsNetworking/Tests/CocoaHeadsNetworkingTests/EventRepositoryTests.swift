import CocoaHeadsCore
import Foundation
import Testing

@testable import CocoaHeadsNetworking

@Suite("Catalog requests, mocks, and persistent fallback")
struct EventRepositoryTests {
  @Test("Mock fixtures exercise the catalog without invoking HTTP")
  func mockCatalog() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let transport = StubTransport()
    let repository = EventRepository(
      configuration: .init(environment: .mock), transport: transport,
      cacheDirectory: storage.directory, now: { fixtureNow }, mockDelay: .zero)
    let snapshot = try await repository.catalog()
    #expect(!snapshot.isStale)
    #expect(snapshot.cachedAt == fixtureNow)
    #expect(snapshot.content.chapters.count == 7)
    let events = snapshot.content.events
    #expect(events.contains { if case .upcoming = $0.phase(at: fixtureNow) { true } else { false } })
    #expect(events.contains { if case .ongoing = $0.phase(at: fixtureNow) { true } else { false } })
    #expect(events.contains { if case .endedToday = $0.phase(at: fixtureNow) { true } else { false } })
    #expect(events.contains { if case .past = $0.phase(at: fixtureNow) { true } else { false } })
    #expect(events.contains { $0.isFeatured && $0.format == .hybrid })
    #expect(events.contains { $0.format == .online })
    #expect(!events.contains { $0.chapterID == "curitiba" })
    #expect(events.contains { $0.imageURL == CatalogFixtures.heroImageURL })
    #expect(events.contains { $0.imageURL == nil })
    let first = try #require(events.first)
    let detail = try await repository.event(id: first.id)
    #expect(detail.content == first)
    #expect(await transport.requests.isEmpty)
  }

  @Test("Empty mock preserves selectable cities and missing details return 404")
  func emptyMock() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let repository = EventRepository(
      configuration: .init(environment: .mock, scenario: .empty),
      cacheDirectory: storage.directory, mockDelay: .zero)
    let snapshot = try await repository.catalog()
    #expect(snapshot.content.events.isEmpty)
    #expect(!snapshot.content.chapters.isEmpty)
    await #expect(throws: ScreenLoadingError.httpStatus(404)) {
      try await repository.event(id: "missing")
    }
  }

  @Test("A running mock repository refreshes its scenarios on a later day")
  func mockClockAdvances() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let clock = AdvancingTestClock(fixtureNow)
    let repository = EventRepository(
      configuration: .init(environment: .mock),
      cacheDirectory: storage.directory, now: { clock.now }, mockDelay: .zero)
    let first = try await repository.catalog()
    let originalLive = try #require(first.content.events.first { $0.id == "demo-sp-live" })
    let originalUpcoming = try #require(first.content.events.first { $0.id == "demo-bh-concurrency" })
    #expect(originalUpcoming.endDate == nil)

    clock.advance(by: 86_400)
    let tomorrow = try await repository.catalog()
    #expect(tomorrow.content.events.map(\.id) == first.content.events.map(\.id))
    #expect(tomorrow.cachedAt == clock.now)
    let live = try #require(tomorrow.content.events.first { $0.id == "demo-sp-live" })
    let upcoming = try #require(tomorrow.content.events.first { $0.id == "demo-bh-concurrency" })
    #expect(live.startDate == originalLive.startDate.addingTimeInterval(86_400))
    #expect(upcoming.startDate == originalUpcoming.startDate.addingTimeInterval(86_400))
    #expect(live.phase(at: clock.now) == .ongoing)
    #expect(upcoming.phase(at: clock.now) == .upcoming)
    #expect(tomorrow.content.events.contains { $0.phase(at: clock.now) == .endedToday })
    #expect(tomorrow.content.events.contains { $0.phase(at: clock.now) == .past })

    // A direct detail request also consults the current clock, without another feed request.
    clock.advance(by: 86_400)
    let detail = try await repository.event(id: live.id)
    #expect(detail.content.startDate == originalLive.startDate.addingTimeInterval(172_800))
    #expect(detail.content.phase(at: clock.now) == .ongoing)
    #expect(detail.cachedAt == clock.now)
  }

  @Test(
    "Mock failures reproduce distinct error states",
    arguments: [
      MockScenario.offline, .serverError, .unsupported, .malformed
    ])
  func mockFailure(scenario: MockScenario) async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let transport = StubTransport()
    let repository = EventRepository(
      configuration: .init(environment: .mock, scenario: scenario),
      transport: transport, cacheDirectory: storage.directory, mockDelay: .zero)
    do {
      _ = try await repository.catalog()
      Issue.record("Expected the selected mock failure")
    } catch {
      switch scenario {
      case .offline: #expect((error as? URLError)?.code == .notConnectedToInternet)
      case .serverError: #expect(error as? ScreenLoadingError == .httpStatus(503))
      case .unsupported: #expect(error as? ScreenLoadingError == .unsupportedScreen)
      case .malformed: #expect(error as? ScreenLoadingError == .invalidResponse)
      default: Issue.record("Unexpected scenario")
      }
    }
    #expect(await transport.requests.isEmpty)
  }

  @Test("Live requests use the configured server and persist complete feed events")
  func liveAndPersistence() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let first = try #require(catalog.events.first)
    let transport = StubTransport([.response(try response(catalog, screen: CatalogScreen.feed))])
    let configuration = EventClientConfiguration(environment: .production, baseURL: try testURL())
    let repository = EventRepository(
      configuration: configuration, transport: transport,
      cacheDirectory: storage.directory, now: { fixtureNow })
    #expect(await repository.cachedCatalog() == nil)
    let fresh = try await repository.catalog()
    #expect(!fresh.isStale)
    let requests = await transport.requests
    #expect(requests.count == 1)
    #expect(requests.first?.url?.absoluteString == "https://catalog.example.com/v1/screens/events")
    #expect(requests.first?.httpMethod == "GET")
    #expect(requests.first?.value(forHTTPHeaderField: "Accept") == "application/json")

    let offline = StubTransport([.failure(.notConnectedToInternet)])
    let reopened = EventRepository(
      configuration: configuration, transport: offline,
      cacheDirectory: storage.directory)
    let cached = try #require(await reopened.cachedCatalog())
    #expect(cached.isStale)
    #expect(cached.cachedAt == fixtureNow)
    #expect(cached.content.events == catalog.events)
    let event = try #require(await reopened.cachedEvent(id: first.id))
    #expect(event.content == first)
    let fallback = try await reopened.event(id: first.id)
    #expect(fallback.isStale)
    #expect(fallback.content == first)
  }

  @Test("Ordinary refresh failures keep the last valid document", arguments: [0, 1, 2])
  func staleFallback(failure: Int) async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let outcomes: [StubTransport.Outcome] = [
      .failure(.notConnectedToInternet),
      .response(EventHTTPResponse(data: Data(), statusCode: 503)),
      .response(EventHTTPResponse(data: Data("broken JSON".utf8), statusCode: 200))
    ]
    let transport = StubTransport([
      .response(try response(catalog, screen: CatalogScreen.feed)), outcomes[failure]
    ])
    let repository = EventRepository(
      configuration: .init(environment: .localhost, baseURL: try testURL()),
      transport: transport, cacheDirectory: storage.directory, now: { fixtureNow })
    _ = try await repository.catalog()
    let stale = try await repository.catalog()
    #expect(stale.isStale)
    #expect(stale.content.events == catalog.events)
    #expect(stale.cachedAt == fixtureNow)
    #expect(await repository.cachedCatalog()?.content.events == catalog.events)
  }

  @Test(
    "Unsupported screens and versions override cache, without destroying it",
    arguments: [
      #"{"schemaVersion":2,"screen":"eventFeed","content":null}"#,
      #"{"schemaVersion":1,"screen":"newFeed","content":{"future":true}}"#
    ])
  func unsupportedPreservesCache(payload: String) async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let transport = StubTransport([
      .response(try response(catalog, screen: CatalogScreen.feed)),
      .response(EventHTTPResponse(data: Data(payload.utf8), statusCode: 200)),
      .failure(.notConnectedToInternet)
    ])
    let repository = EventRepository(
      configuration: .init(environment: .production, baseURL: try testURL()),
      transport: transport, cacheDirectory: storage.directory)
    _ = try await repository.catalog()
    await #expect(throws: ScreenLoadingError.unsupportedScreen) { try await repository.catalog() }
    #expect(await repository.cachedCatalog()?.content.events == catalog.events)
    #expect(try await repository.catalog().isStale)
  }

  @Test("Missing production configuration never silently serves fixtures")
  func missingConfiguration() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let transport = StubTransport()
    let repository = EventRepository(
      configuration: .init(environment: .production), transport: transport,
      cacheDirectory: storage.directory)
    await #expect(throws: ScreenLoadingError.missingServerConfiguration) { try await repository.catalog() }
    #expect(await transport.requests.isEmpty)
  }

  @Test("Caches are isolated by both environment and server")
  func isolatedCaches() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let server = try testURL()
    let production = EventRepository(
      configuration: .init(environment: .production, baseURL: server),
      transport: StubTransport([.response(try response(catalog, screen: CatalogScreen.feed))]),
      cacheDirectory: storage.directory)
    _ = try await production.catalog()
    let local = EventRepository(
      configuration: .init(environment: .localhost, baseURL: server),
      cacheDirectory: storage.directory)
    let other = EventRepository(
      configuration: .init(
        environment: .production,
        baseURL: try testURL("https://another.example.com")), cacheDirectory: storage.directory)
    let mock = EventRepository(configuration: .init(environment: .mock), cacheDirectory: storage.directory)
    #expect(await local.cachedCatalog() == nil)
    #expect(await other.cachedCatalog() == nil)
    #expect(await mock.cachedCatalog() == nil)
  }

  @Test("Transport cancellation never returns a stale success")
  func cancellation() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let transport = StubTransport([
      .response(try response(catalog, screen: CatalogScreen.feed)), .cancelled, .failure(.cancelled)
    ])
    let repository = EventRepository(
      configuration: .init(environment: .production, baseURL: try testURL()),
      transport: transport, cacheDirectory: storage.directory)
    _ = try await repository.catalog()
    await #expect(throws: CancellationError.self) { try await repository.catalog() }
    await #expect(throws: CancellationError.self) { try await repository.catalog() }
  }

  @Test("Offline mock reuses only previously viewed mock content")
  func offlineMockCache() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let standard = EventRepository(
      configuration: .init(environment: .mock), cacheDirectory: storage.directory,
      now: { fixtureNow }, mockDelay: .zero)
    let fresh = try await standard.catalog()
    let offline = EventRepository(
      configuration: .init(environment: .mock, scenario: .offline),
      cacheDirectory: storage.directory, mockDelay: .zero)
    let stale = try await offline.catalog()
    #expect(stale.isStale)
    #expect(stale.content.events == fresh.content.events)
  }
}
