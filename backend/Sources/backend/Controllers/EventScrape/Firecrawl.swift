import Vapor

// MARK: - Firecrawl Request/Response Models

struct FirecrawlRequest: Content {
  let urls: [String]
  let schema: FirecrawlSchema
}

struct FirecrawlSchema: Codable, Sendable {
  let type: String
  let properties: [String: SchemaProperty]
  let required: [String]?

  init(type: String, properties: [String: SchemaProperty], required: [String]? = nil) {
    self.type = type
    self.properties = properties
    self.required = required
  }
}

struct SchemaProperty: Codable, Sendable {
  let type: String
  let description: String?
  let items: NestedProperty?

  init(type: String, description: String? = nil, items: NestedProperty? = nil) {
    self.type = type
    self.description = description
    self.items = items
  }
}

struct NestedProperty: Codable, Sendable {
  let type: String
  let properties: [String: SchemaProperty]
}

struct FirecrawlExtractionStatus: Content {
  let status: Status

  enum Status: String, Content {
    case completed, processing, failed, cancelled
  }
}

struct FirecrawlResponse<T: Content>: Content {
  let success: Bool
  let data: T?
}

struct FirecrawlExtractResponse: Content {
  let success: Bool
  let id: String
}

enum FirecrawlError: AbortError {
  case missingAPIKey
  case extractionFailed

  var status: HTTPResponseStatus { .internalServerError }
  var reason: String { localizedDescription }
}
