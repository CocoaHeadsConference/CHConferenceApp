import CocoaHeadsCore
import CocoaHeadsNetworking
import Foundation
import Testing

@testable import CocoaHeadsKit

@Suite("Event detail loading and recovery")
@MainActor
struct EventDetailLoaderTests {
  @Test("Ordinary failures retain the visible event and offer retry", arguments: [false, true])
  func failedRefreshRetainsContent(withCache: Bool) async throws {
    let storage = DetailLoaderTestCache()
    defer { storage.remove() }
    let original = try event(title: "Evento recebido no feed")
    let updated = try event(title: "Evento atualizado pelo servidor")
    let fetchedAt = Date(timeIntervalSince1970: 1_800_000_000)
    var outcomes: [DetailLoaderStubTransport.Outcome] = []
    if withCache { outcomes.append(.response(try response(updated))) }
    outcomes.append(.failure(.notConnectedToInternet))
    let transport = DetailLoaderStubTransport(outcomes)
    let repository = try makeRepository(transport: transport, directory: storage.directory, now: fetchedAt)
    let loader = EventDetailLoader(event: original)

    await loader.load(using: repository)
    if withCache {
      #expect(loader.event == updated)
      #expect(!loader.showsRefreshNotice)
      await loader.refresh(using: repository)
    }

    let expectedDate: Date? = withCache ? fetchedAt : nil
    #expect(loader.event == (withCache ? updated : original))
    #expect(loader.lastUpdated == expectedDate)
    #expect(loader.showsRefreshNotice)
    #expect(!loader.isUnsupported)
    #expect(!loader.isRefreshing)
    #expect(await transport.requestCount == (withCache ? 2 : 1))
  }

  @Test("Unsupported detail replaces the screen even when a valid cached event exists")
  func unsupportedTakesPriorityOverCachedContent() async throws {
    let storage = DetailLoaderTestCache()
    defer { storage.remove() }
    let original = try event(title: "Evento recebido no feed")
    let cached = try event(title: "Última versão válida")
    let fetchedAt = Date(timeIntervalSince1970: 1_800_000_000)
    let unsupported = EventHTTPResponse(
      data: Data(#"{"schemaVersion":999,"screen":"eventDetail","content":null}"#.utf8),
      statusCode: 200, contentType: "application/json")
    let transport = DetailLoaderStubTransport([
      .response(try response(cached)), .response(unsupported)
    ])
    let repository = try makeRepository(transport: transport, directory: storage.directory, now: fetchedAt)
    _ = try await repository.event(id: cached.id)
    let loader = EventDetailLoader(event: original)

    await loader.load(using: repository)

    // The view selects the update-required screen using this state, rather than a stale-content notice.
    #expect(loader.isUnsupported)
    #expect(!loader.showsRefreshNotice)
    #expect(!loader.isRefreshing)
    #expect(loader.event == cached)
    #expect(loader.lastUpdated == fetchedAt)
    #expect(await repository.cachedEvent(id: cached.id)?.content == cached)
    #expect(await transport.requestCount == 2)
  }

  @Test("A cancelled initial load can be retried successfully on the same loader")
  func cancellationAllowsAnotherInitialLoad() async throws {
    let storage = DetailLoaderTestCache()
    defer { storage.remove() }
    let original = try event(title: "Evento recebido no feed")
    let updated = try event(title: "Atualizado depois de voltar à tela")
    let fetchedAt = Date(timeIntervalSince1970: 1_800_000_000)
    let transport = DetailLoaderStubTransport([
      .cancelCurrentTask, .response(try response(updated))
    ])
    let repository = try makeRepository(transport: transport, directory: storage.directory, now: fetchedAt)
    let loader = EventDetailLoader(event: original)
    let firstLoad = Task {
      await loader.load(using: repository)
      return Task.isCancelled
    }

    let wasCancelled = await firstLoad.value
    #expect(wasCancelled)
    #expect(loader.event == original)
    #expect(loader.lastUpdated == nil)
    #expect(!loader.showsRefreshNotice)
    #expect(!loader.isRefreshing)

    await loader.load(using: repository)

    #expect(loader.event == updated)
    #expect(loader.lastUpdated == fetchedAt)
    #expect(!loader.showsRefreshNotice)
    #expect(!loader.isUnsupported)
    #expect(!loader.isRefreshing)
    #expect(await transport.requestCount == 2)
  }

  private func makeRepository(
    transport: DetailLoaderStubTransport, directory: URL,
    now: Date
  ) throws -> EventRepository {
    EventRepository(
      configuration: .init(
        environment: .localhost,
        baseURL: try #require(URL(string: "https://detail-tests.example.com"))),
      transport: transport, cacheDirectory: directory, now: { now })
  }

  private func event(title: String) throws -> CommunityEvent {
    CommunityEvent(
      id: "event-42", chapterID: "sp", title: title,
      startDate: Date(timeIntervalSince1970: 1_800_003_600),
      endDate: Date(timeIntervalSince1970: 1_800_010_800),
      summary: "Encontro da comunidade",
      registrationURL: try #require(URL(string: "https://example.com/event/42")))
  }

  private func response(_ event: CommunityEvent) throws -> EventHTTPResponse {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return EventHTTPResponse(
      data: try encoder.encode(ScreenDocument(screen: CatalogScreen.detail, content: event)),
      statusCode: 200, contentType: "application/json")
  }
}

private struct DetailLoaderTestCache {
  let directory = FileManager.default.temporaryDirectory
    .appending(path: "cocoaheads-detail-tests-\(UUID().uuidString)", directoryHint: .isDirectory)

  func remove() {
    try? FileManager.default.removeItem(at: directory)
  }
}

private actor DetailLoaderStubTransport: EventHTTPTransport {
  enum Outcome: Sendable {
    case response(EventHTTPResponse)
    case failure(URLError.Code)
    case cancelCurrentTask
  }

  private var outcomes: [Outcome]
  private(set) var requestCount = 0

  init(_ outcomes: [Outcome]) {
    self.outcomes = outcomes
  }

  func data(for request: URLRequest) async throws -> EventHTTPResponse {
    requestCount += 1
    guard !outcomes.isEmpty else { throw URLError(.badServerResponse) }
    switch outcomes.removeFirst() {
    case .response(let response):
      return response
    case .failure(let code):
      throw URLError(code)
    case .cancelCurrentTask:
      // Cancel the actual child task so the loader's Task.isCancelled recovery is exercised.
      withUnsafeCurrentTask { $0?.cancel() }
      throw CancellationError()
    }
  }
}
