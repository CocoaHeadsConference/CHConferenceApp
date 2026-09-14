import Foundation
import Vapor

/// Catalog and organizer endpoints share ISO-8601 dates, independent of auth's legacy encoding.
enum CatalogJSON {
  static func response<Value: Encodable>(_ value: Value, status: HTTPStatus = .ok) throws -> Response {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom { date, encoder in
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      var container = encoder.singleValueContainer()
      try container.encode(formatter.string(from: date))
    }
    return Response(
      status: status, headers: ["Content-Type": "application/json; charset=utf-8"],
      body: .init(data: try encoder.encode(value)))
  }

  static func decode<Value: Decodable>(_ type: Value.Type, from req: Request) throws -> Value {
    guard let body = req.body.data, let data = body.getData(at: body.readerIndex, length: body.readableBytes) else {
      throw Abort(.badRequest, reason: "Envie os dados da solicitação.")
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let value = try decoder.singleValueContainer().decode(String.self)
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      if let date = formatter.date(from: value) { return date }
      formatter.formatOptions = [.withInternetDateTime]
      if let date = formatter.date(from: value) { return date }
      throw DecodingError.dataCorrupted(
        .init(codingPath: decoder.codingPath, debugDescription: "Expected an ISO-8601 date"))
    }
    do { return try decoder.decode(type, from: data) } catch {
      throw Abort(.badRequest, reason: "Os dados enviados estão incompletos ou inválidos.")
    }
  }
}
