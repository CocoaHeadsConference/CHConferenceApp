import CocoaHeadsCore
import CocoaHeadsNetworking
import Foundation
import Testing

@testable import CocoaHeadsKit

@Suite("Catalog shared by events and search")
@MainActor
struct EventCatalogLoaderTests {
  @Test("Switching tabs shares one load even when the departing tab's task is cancelled")
  func tabsShareCatalog() async throws {
    let storage = temporaryCache()
    defer { try? FileManager.default.removeItem(at: storage) }
    let transport = try CatalogLoaderTransport()
    let loader = try makeLoader(transport: transport, storage: storage)

    let eventsTab = Task { await loader.load() }
    eventsTab.cancel()
    async let searchTab: Void = loader.load()
    await eventsTab.value
    await searchTab
    await loader.load()

    #expect(await transport.requestCount == 1)
    #expect(loader.snapshot?.content.chapters.first?.name == "São Paulo")
    #expect(loader.hasLoaded)
    #expect(!loader.isLoading)
    #expect(loader.snapshot?.isStale == false)
  }

  @Test("Shared refresh keeps offline content and replaces unsupported screens")
  func refreshRecovery() async throws {
    let storage = temporaryCache()
    defer { try? FileManager.default.removeItem(at: storage) }
    let transport = try CatalogLoaderTransport()
    let loader = try makeLoader(transport: transport, storage: storage)
    await loader.load()

    await transport.setOutcome(.offline)
    await loader.refresh()
    #expect(loader.snapshot?.content.chapters.first?.name == "São Paulo")
    #expect(loader.snapshot?.isStale == true)
    #expect(!loader.isUnsupported)

    await transport.setOutcome(.unsupported)
    await loader.refresh()
    #expect(loader.isUnsupported)
    #expect(!loader.isRefreshing)
    #expect(await transport.requestCount == 3)
  }

  private func temporaryCache() -> URL {
    FileManager.default.temporaryDirectory.appending(path: "catalog-loader-tests-\(UUID().uuidString)")
  }

  private func makeLoader(transport: CatalogLoaderTransport, storage: URL) throws -> EventCatalogLoader {
    EventCatalogLoader(
      repository: EventRepository(
        configuration: .init(
          environment: .localhost, baseURL: try #require(URL(string: "https://catalog.example.com"))),
        transport: transport, cacheDirectory: storage))
  }
}

private actor CatalogLoaderTransport: EventHTTPTransport {
  enum Outcome { case catalog, offline, unsupported }
  private var outcome = Outcome.catalog
  private let catalogData: Data
  private(set) var requestCount = 0

  init() throws {
    let catalog = EventCatalog(chapters: [.init(id: "sp", name: "São Paulo")], events: [])
    catalogData = try JSONEncoder().encode(ScreenDocument(screen: CatalogScreen.feed, content: catalog))
  }

  func setOutcome(_ outcome: Outcome) { self.outcome = outcome }

  func data(for request: URLRequest) async throws -> EventHTTPResponse {
    requestCount += 1
    switch outcome {
    case .catalog:
      return EventHTTPResponse(data: catalogData, statusCode: 200, contentType: "application/json")
    case .offline:
      throw URLError(.notConnectedToInternet)
    case .unsupported:
      return EventHTTPResponse(
        data: Data(#"{"schemaVersion":999,"screen":"eventFeed","content":null}"#.utf8),
        statusCode: 200, contentType: "application/json")
    }
  }
}
