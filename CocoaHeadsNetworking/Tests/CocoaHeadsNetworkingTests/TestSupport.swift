import CocoaHeadsCore
import Foundation
import Synchronization
import Testing

@testable import CocoaHeadsNetworking

let fixtureNow = Date(timeIntervalSince1970: 1_789_329_600)

final class AdvancingTestClock: Sendable {
  private let instant: Mutex<Date>

  init(_ date: Date) { instant = Mutex(date) }

  var now: Date { instant.withLock { $0 } }

  func advance(by seconds: TimeInterval) {
    instant.withLock { $0 = $0.addingTimeInterval(seconds) }
  }
}

func testURL(_ value: String = "https://catalog.example.com") throws -> URL {
  try #require(URL(string: value))
}

struct TestCache {
  let directory = FileManager.default.temporaryDirectory
    .appending(path: "CocoaHeadsNetworkingTests-\(UUID().uuidString)")

  func remove() { try? FileManager.default.removeItem(at: directory) }
}

func response<Content: Codable & Sendable>(
  _ content: Content, screen: String,
  version: Int = 1
) throws -> EventHTTPResponse {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .iso8601
  return EventHTTPResponse(
    data: try encoder.encode(ScreenDocument(schemaVersion: version, screen: screen, content: content)),
    statusCode: 200, contentType: "application/json")
}

actor StubTransport: EventHTTPTransport {
  enum Outcome: Sendable {
    case response(EventHTTPResponse)
    case failure(URLError.Code)
    case cancelled
  }

  private var outcomes: [Outcome]
  private(set) var requests: [URLRequest] = []

  init(_ outcomes: [Outcome] = []) { self.outcomes = outcomes }

  func data(for request: URLRequest) async throws -> EventHTTPResponse {
    requests.append(request)
    guard !outcomes.isEmpty else {
      Issue.record("Unexpected transport call: \(request.url?.absoluteString ?? "missing URL")")
      throw ScreenLoadingError.invalidResponse
    }
    switch outcomes.removeFirst() {
    case .response(let response): return response
    case .failure(let code): throw URLError(code)
    case .cancelled: throw CancellationError()
    }
  }
}
