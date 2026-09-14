import CocoaHeadsCore
import Foundation
import Testing

@testable import CocoaHeadsNetworking

@Suite("Featured content wire validation and persistence")
struct CatalogFeatureValidationTests {
  @Test("Independent event, chapter, and national features survive a disk-cache reopen")
  func persistentFeatures() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let configuration = EventClientConfiguration(environment: .production, baseURL: try testURL())
    let repository = EventRepository(
      configuration: configuration,
      transport: StubTransport([.response(try response(catalog, screen: CatalogScreen.feed))]),
      cacheDirectory: storage.directory, now: { fixtureNow })
    let loaded = try await repository.catalog()
    #expect(loaded.content.features == catalog.features)
    let floripa = loaded.content.features.filter { $0.chapterID == "florianopolis" }
    #expect(floripa.count == 2)
    #expect(floripa.first?.destination == .event(id: "demo-floripa-hackathon"))
    #expect(loaded.content.features.contains { $0.chapterID == nil })

    let reopened = EventRepository(
      configuration: configuration,
      transport: StubTransport([.failure(.notConnectedToInternet)]),
      cacheDirectory: storage.directory)
    let cached = try #require(await reopened.cachedCatalog())
    let fallback = try await reopened.catalog()
    #expect(cached.content.features == catalog.features)
    #expect(fallback.content.features == catalog.features)
    #expect(fallback.cachedAt == fixtureNow)
    #expect(fallback.isStale)
  }

  @Test(
    "Invalid featured content never enters the cache",
    arguments: [
      "blankID", "blankTitle", "duplicateID", "unknownChapter", "blankChapter",
      "missingEvent", "blankEvent", "externalScheme", "imageScheme", "blankPlaceholder"
    ])
  func invalidFeature(variation: String) async throws {
    let storage = TestCache()
    defer { storage.remove() }
    var catalog = CatalogFixtures.catalog(now: fixtureNow)
    switch variation {
    case "blankID":
      catalog.features[0] = CatalogFeature(
        id: " \n\t ", title: "Destaque", destination: .placeholder(title: "Em breve"))
    case "blankTitle": catalog.features[0].title = " \n\t "
    case "duplicateID": catalog.features.append(catalog.features[0])
    case "unknownChapter": catalog.features[0].chapterID = "unknown"
    case "blankChapter": catalog.features[0].chapterID = ""
    case "missingEvent": catalog.features[0].destination = .event(id: "nonexistent-event")
    case "blankEvent": catalog.features[0].destination = .event(id: " \n\t ")
    case "externalScheme":
      catalog.features[0].destination = .externalURL(try testURL("file:///private/example"))
    case "imageScheme": catalog.features[0].imageURL = try testURL("file:///private/image.png")
    default: catalog.features[0].destination = .placeholder(title: " \n\t ")
    }
    let repository = EventRepository(
      configuration: .init(environment: .production, baseURL: try testURL()),
      transport: StubTransport([.response(try response(catalog, screen: CatalogScreen.feed))]),
      cacheDirectory: storage.directory)
    await #expect(throws: ScreenLoadingError.invalidResponse) { try await repository.catalog() }
    #expect(await repository.cachedCatalog() == nil)
  }

  @Test("Unknown feature destinations require an update and preserve the last valid catalog")
  func unsupportedDestination() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let unsupported = try featureResponse(destination: ["type": "video", "videoID": "future"])
    let repository = EventRepository(
      configuration: .init(environment: .production, baseURL: try testURL()),
      transport: StubTransport([
        .response(try response(catalog, screen: CatalogScreen.feed)),
        .response(unsupported), .failure(.notConnectedToInternet)
      ]), cacheDirectory: storage.directory, now: { fixtureNow })
    _ = try await repository.catalog()
    await #expect(throws: ScreenLoadingError.unsupportedScreen) { try await repository.catalog() }
    let cached = try #require(await repository.cachedCatalog())
    #expect(cached.content.features == catalog.features)
    let fallback = try await repository.catalog()
    #expect(fallback.content.features == catalog.features)
    #expect(fallback.cachedAt == fixtureNow)
    #expect(fallback.isStale)
  }

  @Test("A known destination missing its payload is invalid, without claiming the app needs an update")
  func malformedDestination() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let repository = EventRepository(
      configuration: .init(environment: .production, baseURL: try testURL()),
      transport: StubTransport([.response(try featureResponse(destination: ["type": "event"]))]),
      cacheDirectory: storage.directory)
    await #expect(throws: ScreenLoadingError.invalidResponse) { try await repository.catalog() }
    #expect(await repository.cachedCatalog() == nil)
  }

  @Test("Older wire documents and their disk caches keep legacy featured events")
  func legacyCatalogCache() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let catalog = CatalogFixtures.catalog(now: fixtureNow)
    let data = try response(catalog, screen: CatalogScreen.feed).data
    var document = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    var content = try #require(document["content"] as? [String: Any])
    content.removeValue(forKey: "features")
    document["content"] = content
    let configuration = EventClientConfiguration(environment: .production, baseURL: try testURL())
    let repository = EventRepository(
      configuration: configuration,
      transport: StubTransport([
        .response(
          EventHTTPResponse(
            data: try JSONSerialization.data(withJSONObject: document), statusCode: 200))
      ]),
      cacheDirectory: storage.directory)
    let fresh = try await repository.catalog()
    #expect(fresh.content.features.isEmpty)
    #expect(fresh.content.events.first { $0.id == "demo-floripa-hackathon" }?.isFeatured == true)

    let reopened = EventRepository(configuration: configuration, cacheDirectory: storage.directory)
    let cached = try #require(await reopened.cachedCatalog())
    #expect(cached.content.features.isEmpty)
    #expect(cached.content.events == fresh.content.events)
  }

  private func featureResponse(destination: [String: String]) throws -> EventHTTPResponse {
    let data = try response(CatalogFixtures.catalog(now: fixtureNow), screen: CatalogScreen.feed).data
    var document = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    var content = try #require(document["content"] as? [String: Any])
    var features = try #require(content["features"] as? [[String: Any]])
    features[0]["destination"] = destination
    content["features"] = features
    document["content"] = content
    return EventHTTPResponse(data: try JSONSerialization.data(withJSONObject: document), statusCode: 200)
  }
}
