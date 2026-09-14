import CocoaHeadsCore
import Fluent
import FluentSQL
import Vapor

struct OrganizerAuthorization {
  let user: User
  let chapters: [ChapterSummary]

  static func load(userID: UUID, on db: any Database) async throws -> Self {
    guard let user = try await User.find(userID, on: db) else { throw Abort(.unauthorized) }
    let chapters: [ChapterSummary]
    switch user.role {
    case .admin:
      chapters = try await CatalogChapter.query(on: db).sort(\.$name).all().map { try $0.summary }
    case .organizer:
      let ids = try await OrganizerChapter.query(on: db).filter(\.$userID == userID).all().map(\.chapterID)
      chapters =
        ids.isEmpty
        ? [] : try await CatalogChapter.query(on: db).filter(\.$id ~~ ids).sort(\.$name).all().map { try $0.summary }
    case .user:
      chapters = []
    }
    return Self(user: user, chapters: chapters)
  }

  var dto: OrganizerAccess { get throws { OrganizerAccess(user: try user.dto, chapters: chapters) } }

  func requireOrganizer() throws {
    guard user.role == .organizer || user.role == .admin else {
      throw Abort(.forbidden, reason: "Sua conta ainda não tem acesso de organização.")
    }
  }

  func requireChapter(_ id: String) throws {
    try requireOrganizer()
    guard chapters.contains(where: { $0.id == id }) else {
      throw Abort(.forbidden, reason: "Você não tem permissão para editar eventos deste capítulo.")
    }
  }

  func requireEvent(_ event: CatalogEvent) throws {
    try requireChapter(event.chapterID)
    if let published = event.publicSnapshot { try requireChapter(published.chapterID) }
  }

  /// Lock the current DB identity and assignments throughout mutations. Manual role updates
  /// or assignment revocations serialize with publishing instead of racing an old JWT claim.
  static func lock(userID: UUID, on db: any Database) async throws -> Self {
    guard let sql = db as? any SQLDatabase else { throw Abort(.internalServerError) }
    try await sql.raw("SELECT id FROM users WHERE id = \(bind: userID) FOR UPDATE").run()
    try await sql.raw("SELECT id FROM organizer_chapters WHERE user_id = \(bind: userID) FOR SHARE").run()
    return try await load(userID: userID, on: db)
  }

  static func lockEvent(id: String, on db: any Database) async throws -> CatalogEvent {
    guard let sql = db as? any SQLDatabase else { throw Abort(.internalServerError) }
    try await sql.raw("SELECT id FROM catalog_events WHERE id = \(bind: id) FOR UPDATE").run()
    guard let event = try await CatalogEvent.find(id, on: db) else { throw Abort(.notFound) }
    return event
  }
}
