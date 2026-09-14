import Foundation

public struct EventHTTPResponse: Sendable {
  public let data: Data
  public let statusCode: Int
  public let contentType: String?

  public init(data: Data, statusCode: Int, contentType: String? = nil) {
    self.data = data
    self.statusCode = statusCode
    self.contentType = contentType
  }
}

/// One injectable boundary for HTTP. Mock mode never calls this transport.
public protocol EventHTTPTransport: Sendable {
  func data(for request: URLRequest) async throws -> EventHTTPResponse
}

public struct URLSessionEventTransport: EventHTTPTransport {
  private let session: URLSession

  public init() {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.urlCache = nil
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    configuration.timeoutIntervalForRequest = 30
    session = URLSession(configuration: configuration)
  }

  public init(session: URLSession) {
    self.session = session
  }

  public func data(for request: URLRequest) async throws -> EventHTTPResponse {
    let (data, response) = try await session.data(for: request)
    guard let response = response as? HTTPURLResponse else {
      throw ScreenLoadingError.invalidResponse
    }
    return EventHTTPResponse(
      data: data, statusCode: response.statusCode,
      contentType: response.value(forHTTPHeaderField: "Content-Type"))
  }
}

func isCancellation(_ error: any Error) -> Bool {
  error is CancellationError || (error as? URLError)?.code == .cancelled
}
