import CocoaHeadsCore
import Foundation

/// Authenticated writes have no cached-success fallback. Public screens retain their own offline cache.
public actor OrganizerRepository {
  private let account: AccountClient
  private let mockStore: MockOrganizerStore?

  public init(account: AccountClient, mockStore: MockOrganizerStore? = nil) {
    self.account = account
    self.mockStore = account.isMock ? mockStore : nil
  }

  public func access() async throws -> OrganizerAccess {
    if let mockStore { return try await mockStore.access(user: account.currentUser()) }
    return try await get(["v1", "organizer", "access"])
  }

  public func events() async throws -> [OrganizerEventRecord] {
    if let mockStore { return try await mockStore.events(user: account.currentUser()) }
    return try await get(["v1", "organizer", "events"])
  }

  public func save(
    draft: OrganizerEventDraft, replacing record: OrganizerEventRecord? = nil
  ) async throws -> OrganizerEventRecord {
    if let mockStore {
      return try await mockStore.save(draft: draft, replacing: record, user: account.currentUser())
    }
    var path = ["v1", "organizer", "events"]
    if let record { path.append(record.id) }
    let body = try OrganizerJSON.encoder().encode(
      SaveOrganizerEventRequest(draft: draft, expectedRevision: record?.revision))
    let data = try await account.authenticatedRequest(path: path, method: record == nil ? "POST" : "PUT", body: body)
    return try OrganizerJSON.decoder().decode(OrganizerEventRecord.self, from: data)
  }

  public func publish(_ record: OrganizerEventRecord) async throws -> OrganizerEventRecord {
    if let mockStore { return try await mockStore.publish(record, user: account.currentUser()) }
    let body = try OrganizerJSON.encoder().encode(EventRevisionRequest(revision: record.revision))
    let data = try await account.authenticatedRequest(
      path: ["v1", "organizer", "events", record.id, "publish"], method: "POST", body: body)
    return try OrganizerJSON.decoder().decode(OrganizerEventRecord.self, from: data)
  }

  private func get<Value: Decodable & Sendable>(_ path: [String]) async throws -> Value {
    let data = try await account.authenticatedRequest(path: path, method: "GET")
    return try OrganizerJSON.decoder().decode(Value.self, from: data)
  }
}

enum OrganizerJSON {
  static func encoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }

  static func decoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let string = try decoder.singleValueContainer().decode(String.self)
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      if let date = formatter.date(from: string) { return date }
      formatter.formatOptions = [.withInternetDateTime]
      if let date = formatter.date(from: string) { return date }
      throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid date"))
    }
    return decoder
  }
}
