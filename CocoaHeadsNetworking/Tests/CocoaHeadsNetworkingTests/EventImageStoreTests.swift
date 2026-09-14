import Foundation
import Testing

@testable import CocoaHeadsNetworking

@Suite("Persistent event media")
struct EventImageStoreTests {
  @Test("Mock heroes load from the bundle and remain cached without HTTP")
  func bundledHero() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let transport = StubTransport()
    let store = EventImageStore(
      configuration: .init(environment: .mock), transport: transport,
      cacheDirectory: storage.directory)
    let bytes = try await store.data(for: CatalogFixtures.heroImageURL)
    #expect(bytes.starts(with: [0x89, 0x50, 0x4E, 0x47]))
    let reopened = EventImageStore(
      configuration: .init(environment: .mock), transport: transport,
      cacheDirectory: storage.directory)
    #expect(try await reopened.data(for: CatalogFixtures.heroImageURL) == bytes)
    #expect(await transport.requests.isEmpty)
  }

  @Test("Viewed media survives a new store instance and does not request HTTP again")
  func persistentImage() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let bytes = Data([0x89, 0x50, 0x4E, 0x47])
    let transport = StubTransport([
      .response(EventHTTPResponse(data: bytes, statusCode: 200, contentType: "image/png"))
    ])
    let configuration = EventClientConfiguration(environment: .production, baseURL: try testURL())
    let url = try testURL("https://images.example.com/event.png")
    let first = EventImageStore(configuration: configuration, transport: transport, cacheDirectory: storage.directory)
    #expect(try await first.data(for: url) == bytes)
    #expect(try await first.data(for: url) == bytes)
    #expect(await transport.requests.count == 1)
    let untouched = StubTransport()
    let reopened = EventImageStore(
      configuration: configuration, transport: untouched, cacheDirectory: storage.directory)
    #expect(try await reopened.data(for: url) == bytes)
    #expect(await untouched.requests.isEmpty)
  }

  @Test("Mock media never reaches HTTP, including for an accidentally supplied URL")
  func mockImage() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let transport = StubTransport()
    let store = EventImageStore(
      configuration: .init(environment: .mock), transport: transport,
      cacheDirectory: storage.directory)
    let url = try testURL("https://images.example.com/event.png")
    do {
      _ = try await store.data(for: url)
      Issue.record("Expected mock media to stay unavailable")
    } catch {
      #expect((error as? URLError)?.code == .resourceUnavailable)
    }
    #expect(await transport.requests.isEmpty)
  }

  @Test("Error pages cannot be persisted as event images")
  func rejectsErrorPage() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let transport = StubTransport([
      .response(
        EventHTTPResponse(
          data: Data("<html>Unavailable</html>".utf8), statusCode: 200,
          contentType: "text/html")), .failure(.notConnectedToInternet)
    ])
    let configuration = EventClientConfiguration(environment: .production, baseURL: try testURL())
    let store = EventImageStore(configuration: configuration, transport: transport, cacheDirectory: storage.directory)
    let url = try testURL("https://images.example.com/event.png")
    await #expect(throws: ScreenLoadingError.invalidResponse) { try await store.data(for: url) }
    do {
      _ = try await store.data(for: url)
      Issue.record("Invalid image data must not become a cache hit")
    } catch {
      #expect((error as? URLError)?.code == .notConnectedToInternet)
    }
    #expect(await transport.requests.count == 2)
  }

  @Test("Media caches are isolated between production and localhost")
  func imageEnvironmentIsolation() async throws {
    let storage = TestCache()
    defer { storage.remove() }
    let bytes = Data([1, 2, 3])
    let transport = StubTransport([
      .response(EventHTTPResponse(data: bytes, statusCode: 200, contentType: "image/jpeg"))
    ])
    let server = try testURL()
    let imageURL = try testURL("https://images.example.com/shared.jpg")
    let production = EventImageStore(
      configuration: .init(environment: .production, baseURL: server),
      transport: transport, cacheDirectory: storage.directory)
    _ = try await production.data(for: imageURL)
    let offline = StubTransport([.failure(.notConnectedToInternet)])
    let local = EventImageStore(
      configuration: .init(environment: .localhost, baseURL: server),
      transport: offline, cacheDirectory: storage.directory)
    do {
      _ = try await local.data(for: imageURL)
      Issue.record("Localhost must not use a production image cache")
    } catch {
      #expect((error as? URLError)?.code == .notConnectedToInternet)
    }
    #expect(await offline.requests.count == 1)
  }
}
