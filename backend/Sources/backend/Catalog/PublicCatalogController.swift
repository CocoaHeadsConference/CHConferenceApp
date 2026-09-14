import CocoaHeadsCore
import Fluent
import Vapor

/// Deliberately registered on the public router, before API-key, attestation, or user gates.
struct PublicCatalogController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let screens = routes.grouped("v1", "screens", "events")
    screens.get(use: catalog)
    screens.get(":id", use: event)
  }
  @Sendable func catalog(req: Request) async throws -> Response {
    let chapters = try await CatalogChapter.query(on: req.db).sort(\.$name).all().map { try $0.summary }
    let events = try await CatalogEvent.query(on: req.db).all().compactMap(\.publicSnapshot)
      .sorted { $0.startDate < $1.startDate }
    return try CatalogJSON.response(
      ScreenDocument(screen: CatalogScreen.feed, content: EventCatalog(chapters: chapters, events: events)))
  }
  @Sendable func event(req: Request) async throws -> Response {
    guard let id = req.parameters.get("id"),
      let event = try await CatalogEvent.find(id, on: req.db)?.publicSnapshot
    else { throw Abort(.notFound) }
    return try CatalogJSON.response(ScreenDocument(screen: CatalogScreen.detail, content: event))
  }
}
