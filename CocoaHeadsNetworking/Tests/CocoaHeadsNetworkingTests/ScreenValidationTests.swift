import CocoaHeadsCore
import Foundation
import Testing

@testable import CocoaHeadsNetworking

@Suite("Screen wire contract")
struct ScreenValidationTests {
  @Test(
    "Malformed payloads are not confused with an unsupported version",
    arguments: [
      "{broken", #"{"screen":"eventFeed","content":{}}"#,
      #"{"schemaVersion":1,"screen":"eventFeed","content":{}}"#
    ])
  func malformed(payload: String) async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let transport = StubTransport([.response(EventHTTPResponse(data: Data(payload.utf8), statusCode: 200))])
    let repository = EventRepository(
      configuration: .init(environment: .production, baseURL: try testURL()),
      transport: transport, cacheDirectory: storage.directory)
    await #expect(throws: ScreenLoadingError.invalidResponse) { try await repository.catalog() }
    #expect(await repository.cachedCatalog() == nil)
  }

  @Test("Event IDs are encoded as one path component, including under a base path")
  func eventPath() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let event = CommunityEvent(
      id: "demo/sp ?", chapterID: "sao-paulo", title: "Encontro",
      startDate: fixtureNow, endDate: fixtureNow.addingTimeInterval(3_600), summary: "Vamos conversar.",
      registrationURL: try testURL("https://example.com/inscricao"))
    let transport = StubTransport([.response(try response(event, screen: CatalogScreen.detail))])
    let repository = EventRepository(
      configuration: .init(
        environment: .localhost,
        baseURL: try testURL("https://catalog.example.com/api/")), transport: transport,
      cacheDirectory: storage.directory)
    let loaded = try await repository.event(id: event.id)
    #expect(loaded.content.id == event.id)
    #expect(
      await transport.requests.first?.url?.absoluteString
        == "https://catalog.example.com/api/v1/screens/events/demo%2Fsp%20%3F")
  }

  @Test("A detail response for a different event is rejected")
  func mismatchedEvent() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let event = try #require(CatalogFixtures.catalog(now: fixtureNow).events.first)
    let transport = StubTransport([.response(try response(event, screen: CatalogScreen.detail))])
    let repository = EventRepository(
      configuration: .init(environment: .production, baseURL: try testURL()),
      transport: transport, cacheDirectory: storage.directory)
    await #expect(throws: ScreenLoadingError.invalidResponse) { try await repository.event(id: "different") }
    #expect(await repository.cachedEvent(id: "different") == nil)
  }

  @Test("Invalid event dates and timezone cannot poison the cache", arguments: [0, 1, 2])
  func invalidEvent(variation: Int) async throws {
    let storage = TestCache()
    defer { storage.remove() }
    var catalog = CatalogFixtures.catalog(now: fixtureNow)
    switch variation {
    case 0: catalog.events[0].endDate = catalog.events[0].startDate.addingTimeInterval(-1)
    case 1: catalog.events[0].timezoneID = "Not/A_Timezone"
    default: catalog.events[0].chapterID = "nonexistent-chapter"
    }
    let transport = StubTransport([.response(try response(catalog, screen: CatalogScreen.feed))])
    let repository = EventRepository(
      configuration: .init(environment: .production, baseURL: try testURL()),
      transport: transport, cacheDirectory: storage.directory)
    await #expect(throws: ScreenLoadingError.invalidResponse) { try await repository.catalog() }
    #expect(await repository.cachedCatalog() == nil)
  }

  @Test("Blank Q&A session IDs are rejected before reaching the feature", arguments: ["", " \n\t "])
  func blankQASession(sessionID: String) async throws {
    let storage = TestCache()
    defer { storage.remove() }
    var catalog = CatalogFixtures.catalog(now: fixtureNow)
    catalog.events[0].qaSessionID = sessionID
    let transport = StubTransport([.response(try response(catalog, screen: CatalogScreen.feed))])
    let repository = EventRepository(
      configuration: .init(environment: .production, baseURL: try testURL()),
      transport: transport, cacheDirectory: storage.directory)
    await #expect(throws: ScreenLoadingError.invalidResponse) { try await repository.catalog() }
    #expect(await repository.cachedCatalog() == nil)
    #expect(await repository.cachedEvent(id: catalog.events[0].id) == nil)
  }

  @Test("ISO 8601 offsets and fractional seconds survive feed-to-detail persistence")
  func fractionalDates() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let encoded = try response(catalog, screen: CatalogScreen.feed).data
    var document = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
    var content = try #require(document["content"] as? [String: Any])
    var events = try #require(content["events"] as? [[String: Any]])
    events[0]["startDate"] = "2026-09-13T19:00:00.125-03:00"
    events[0]["endDate"] = "2026-09-13T22:00:00-03:00"
    content["events"] = events
    document["content"] = content
    let payload = try JSONSerialization.data(withJSONObject: document)
    let configuration = EventClientConfiguration(environment: .production, baseURL: try testURL())
    let transport = StubTransport([.response(EventHTTPResponse(data: payload, statusCode: 200))])
    let repository = EventRepository(
      configuration: configuration, transport: transport,
      cacheDirectory: storage.directory)
    let fresh = try await repository.catalog()
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    let expected = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 13, hour: 22)))
      .addingTimeInterval(0.125)
    #expect(fresh.content.events[0].startDate == expected)
    let reopened = EventRepository(configuration: configuration, cacheDirectory: storage.directory)
    let cached = try #require(await reopened.cachedEvent(id: catalog.events[0].id))
    #expect(cached.content.startDate == expected)
  }

  @Test("An omitted end time decodes, validates, and remains omitted in cached details")
  func omittedEndDate() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let noEnd = try #require(catalog.events.first { $0.id == "demo-bh-concurrency" })
    #expect(noEnd.endDate == nil)
    let payload = try response(catalog, screen: CatalogScreen.feed)
    let document = try #require(JSONSerialization.jsonObject(with: payload.data) as? [String: Any])
    let content = try #require(document["content"] as? [String: Any])
    let events = try #require(content["events"] as? [[String: Any]])
    let eventJSON = try #require(events.first { $0["id"] as? String == noEnd.id })
    #expect(eventJSON["endDate"] == nil)

    let configuration = EventClientConfiguration(environment: .production, baseURL: try testURL())
    let repository = EventRepository(
      configuration: configuration, transport: StubTransport([.response(payload)]),
      cacheDirectory: storage.directory)
    let fresh = try await repository.catalog()
    #expect(fresh.content.events.first { $0.id == noEnd.id } == noEnd)
    let reopened = EventRepository(configuration: configuration, cacheDirectory: storage.directory)
    let cached = try #require(await reopened.cachedEvent(id: noEnd.id))
    #expect(cached.content.endDate == nil)
    #expect(cached.content.phase(at: noEnd.archiveDate.addingTimeInterval(-1)) == .ongoing)
    #expect(cached.content.phase(at: noEnd.archiveDate) == .past)
  }

  @Test("Corrupt on-disk entries are ignored when reopening")
  func corruptCache() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let configuration = EventClientConfiguration(environment: .mock)
    let repository = EventRepository(
      configuration: configuration, cacheDirectory: storage.directory,
      mockDelay: .zero)
    _ = try await repository.catalog()
    let paths = try FileManager.default.subpathsOfDirectory(atPath: storage.directory.path())
    for path in paths where path.hasSuffix(".json") {
      try Data("corrupted".utf8).write(to: storage.directory.appending(path: path))
    }
    let reopened = EventRepository(configuration: configuration, cacheDirectory: storage.directory)
    #expect(await reopened.cachedCatalog() == nil)
    #expect(await reopened.cachedEvent(id: "demo-sp-swiftui") == nil)
  }
}
