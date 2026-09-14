import CocoaHeadsCore
import Fluent
import Foundation

final class CatalogChapter: Model, @unchecked Sendable {
  static let schema = "catalog_chapters"
  @ID(custom: "id", generatedBy: .user) var id: String?
  @Field(key: "name") var name: String
  @OptionalField(key: "region") var region: String?
  init() {}
  init(_ chapter: ChapterSummary) {
    id = chapter.id
    name = chapter.name
    region = chapter.region
  }
  var summary: ChapterSummary { get throws { ChapterSummary(id: try requireID(), name: name, region: region) } }
}

final class CatalogEvent: Model, @unchecked Sendable {
  static let schema = "catalog_events"
  @ID(custom: "id", generatedBy: .user) var id: String?
  @Field(key: "chapter_id") var chapterID: String
  @Field(key: "draft") var draft: OrganizerEventDraft
  @Field(key: "revision") var revision: Int
  @OptionalField(key: "public_snapshot") var publicSnapshot: CommunityEvent?
  @OptionalField(key: "published_at") var publishedAt: Date?
  @Field(key: "updated_at") var updatedAt: Date
  init() {}
  init(draft: OrganizerEventDraft) {
    id = UUID().uuidString.lowercased()
    chapterID = draft.chapterID
    self.draft = draft
    revision = 1
    updatedAt = Date()
  }
  var record: OrganizerEventRecord {
    get throws {
      OrganizerEventRecord(
        id: try requireID(), draft: draft, revision: revision, publishedAt: publishedAt, updatedAt: updatedAt)
    }
  }
}

final class OrganizerChapter: Model, @unchecked Sendable {
  static let schema = "organizer_chapters"
  @ID(key: .id) var id: UUID?
  @Field(key: "user_id") var userID: UUID
  @Field(key: "chapter_id") var chapterID: String
  init() {}
  init(userID: UUID, chapterID: String) {
    self.userID = userID
    self.chapterID = chapterID
  }
}

struct CreateCatalogTables: AsyncMigration {
  func prepare(on db: any Database) async throws {
    try await db.schema(CatalogChapter.schema)
      .field("id", .string, .identifier(auto: false))
      .field("name", .string, .required).field("region", .string).create()
    try await db.schema(CatalogEvent.schema)
      .field("id", .string, .identifier(auto: false))
      .field("chapter_id", .string, .required, .references(CatalogChapter.schema, "id"))
      .field("draft", .json, .required).field("revision", .int, .required)
      .field("public_snapshot", .json).field("published_at", .datetime)
      .field("updated_at", .datetime, .required).create()
    try await db.schema(OrganizerChapter.schema).id()
      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
      .field("chapter_id", .string, .required, .references(CatalogChapter.schema, "id", onDelete: .cascade))
      .unique(on: "user_id", "chapter_id").create()
  }
  func revert(on db: any Database) async throws {
    try await db.schema(OrganizerChapter.schema).delete()
    try await db.schema(CatalogEvent.schema).delete()
    try await db.schema(CatalogChapter.schema).delete()
  }
}
