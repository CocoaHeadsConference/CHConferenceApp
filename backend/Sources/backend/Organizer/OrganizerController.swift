import CocoaHeadsCore
import Fluent
import Vapor

struct OrganizerController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let organizer =
      routes
      .grouped(AccessTokenPayload.authenticator(), AccessTokenPayload.guardMiddleware())
      .grouped("v1", "organizer")
    organizer.get("access", use: access)
    organizer.get("events", use: events)
    organizer.on(.POST, "events", body: .collect(maxSize: "256kb"), use: create)
    organizer.on(.PUT, "events", ":id", body: .collect(maxSize: "256kb"), use: update)
    organizer.post("events", ":id", "publish", use: publish)
  }

  @Sendable func access(req: Request) async throws -> Response {
    let userID = try req.auth.require(AccessTokenPayload.self).userID
    return try await CatalogJSON.response(OrganizerAuthorization.load(userID: userID, on: req.db).dto)
  }

  @Sendable func events(req: Request) async throws -> Response {
    let authorization = try await OrganizerAuthorization.load(
      userID: req.auth.require(AccessTokenPayload.self).userID, on: req.db)
    try authorization.requireOrganizer()
    let ids = authorization.chapters.map(\.id)
    let records =
      ids.isEmpty
      ? []
      : try await CatalogEvent.query(on: req.db)
        .filter(\.$chapterID ~~ ids).sort(\.$updatedAt, .descending).all()
        .filter { record in record.publicSnapshot.map { ids.contains($0.chapterID) } ?? true }
        .map { try $0.record }
    return try CatalogJSON.response(records)
  }

  @Sendable func create(req: Request) async throws -> Response {
    let input = try CatalogJSON.decode(SaveOrganizerEventRequest.self, from: req)
    guard input.expectedRevision == nil else {
      throw Abort(.badRequest, reason: "Um evento novo não tem revisão anterior.")
    }
    try validateDraft(input.draft)
    let userID = try req.auth.require(AccessTokenPayload.self).userID
    let result = try await req.db.transaction { db in
      let authorization = try await OrganizerAuthorization.lock(userID: userID, on: db)
      try authorization.requireChapter(input.draft.chapterID)
      let event = CatalogEvent(draft: input.draft)
      try await event.create(on: db)
      return try event.record
    }
    return try CatalogJSON.response(result, status: .created)
  }

  @Sendable func update(req: Request) async throws -> Response {
    let input = try CatalogJSON.decode(SaveOrganizerEventRequest.self, from: req)
    guard let id = req.parameters.get("id"), let revision = input.expectedRevision, revision > 0 else {
      throw Abort(.badRequest, reason: "Informe a revisão que você está editando.")
    }
    try validateDraft(input.draft)
    let userID = try req.auth.require(AccessTokenPayload.self).userID
    let result = try await req.db.transaction { db in
      let authorization = try await OrganizerAuthorization.lock(userID: userID, on: db)
      try authorization.requireOrganizer()
      let event = try await OrganizerAuthorization.lockEvent(id: id, on: db)
      try authorization.requireEvent(event)
      try authorization.requireChapter(input.draft.chapterID)
      guard event.revision == revision else { throw conflict() }
      event.draft = input.draft
      event.chapterID = input.draft.chapterID
      event.revision += 1
      // The public copy stays untouched until an explicit publish request.
      event.updatedAt = max(Date(), event.updatedAt.addingTimeInterval(0.001))
      try await event.update(on: db)
      return try event.record
    }
    return try CatalogJSON.response(result)
  }

  @Sendable func publish(req: Request) async throws -> Response {
    let input = try CatalogJSON.decode(EventRevisionRequest.self, from: req)
    guard let id = req.parameters.get("id") else { throw Abort(.badRequest) }
    let userID = try req.auth.require(AccessTokenPayload.self).userID
    let result = try await req.db.transaction { db in
      let authorization = try await OrganizerAuthorization.lock(userID: userID, on: db)
      try authorization.requireOrganizer()
      let event = try await OrganizerAuthorization.lockEvent(id: id, on: db)
      try authorization.requireEvent(event)
      guard event.revision == input.revision else { throw conflict() }
      do { event.publicSnapshot = try event.draft.publishedEvent(id: id) } catch let error as OrganizerValidationError {
        throw Abort(.unprocessableEntity, reason: error.reason)
      }
      let now = Date()
      event.publishedAt = now
      event.updatedAt = now
      event.revision += 1
      try await event.update(on: db)
      return try event.record
    }
    return try CatalogJSON.response(result)
  }

  private func validateDraft(_ draft: OrganizerEventDraft) throws {
    do { try draft.validateForSaving() } catch let error as OrganizerValidationError {
      throw Abort(.unprocessableEntity, reason: error.reason)
    }
  }

  private func conflict() -> Abort {
    Abort(.conflict, reason: "Este evento foi alterado. Atualize os dados antes de continuar.")
  }
}
