import CocoaHeadsCore
import Foundation

enum ScreenCodec {
  private struct Header: Decodable {
    let schemaVersion: Int
    let screen: String
  }

  static func decode<R: ScreenRequest>(_ data: Data, for request: R) throws -> R.Content {
    let decoder = decoder()
    let header: Header
    do {
      header = try decoder.decode(Header.self, from: data)
    } catch {
      throw ScreenLoadingError.invalidResponse
    }
    // Decode this before content: an unknown screen can have an entirely different payload.
    guard header.schemaVersion == CatalogScreen.version, header.screen == request.screen else {
      throw ScreenLoadingError.unsupportedScreen
    }
    do {
      let document = try decoder.decode(ScreenDocument<R.Content>.self, from: data)
      try request.validate(document.content)
      return document.content
    } catch CatalogDecodingError.unsupportedFeatureDestination {
      throw ScreenLoadingError.unsupportedScreen
    } catch {
      throw ScreenLoadingError.invalidResponse
    }
  }

  static func encode<R: ScreenRequest>(_ content: R.Content, for request: R) throws -> Data {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom { date, encoder in
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      var container = encoder.singleValueContainer()
      try container.encode(formatter.string(from: date))
    }
    return try encoder.encode(ScreenDocument(screen: request.screen, content: content))
  }

  private static func decoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let value = try decoder.singleValueContainer().decode(String.self)
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      if let date = formatter.date(from: value) { return date }
      formatter.formatOptions = [.withInternetDateTime]
      if let date = formatter.date(from: value) { return date }
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: decoder.codingPath,
          debugDescription: "Expected an ISO 8601 date with an explicit timezone."))
    }
    return decoder
  }
}
