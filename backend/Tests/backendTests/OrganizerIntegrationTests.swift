import CocoaHeadsCore
import Fluent
import JWT
import NIOConcurrencyHelpers
import Testing
import VaporTesting

@testable import backend

@Suite("Organizer publishing (Postgres)", .serialized, .enabled(if: Environment.get("TEST_DATABASE") != nil))
struct OrganizerIntegrationTests {
  private func configuration(attestDisabled: Bool = true) -> AuthConfiguration {
    AuthConfiguration(
      appleBundleID: "com.cocoaheadsbr.conf", apiKeys: ["test-key"], accessTokenTTL: 900,
      refreshTokenTTL: 3600, accountPurgeGraceDays: 30, appleTeamID: nil,
      appleSignInKeyID: nil, appleSignInPrivateKey: nil, appAttestTeamID: nil,
      appAttestEnvironment: .production, appAttestDisabled: attestDisabled)
  }

  private func withApp(_ test: (Application) async throws -> Void) async throws {
    // This check must run before app creation/configuration and outside cleanup:
    // autoRevert drops every migrated table in the selected database.
    let databaseName = try #require(
      Environment.get("DATABASE_NAME"), "Set DATABASE_NAME explicitly to a disposable database ending in _test.")
    try #require(
      databaseName.hasSuffix("_test"), "Refusing destructive tests against a database without the _test suffix.")
    let app = try await Application.make(.testing)
    do {
      try await configure(app)
      app.authConfiguration = configuration()
      try await app.autoMigrate()
      try await CatalogChapter(ChapterSummary(id: "sp", name: "São Paulo")).create(on: app.db)
      try await CatalogChapter(ChapterSummary(id: "rj", name: "Rio de Janeiro")).create(on: app.db)
      try await test(app)
      try await app.autoRevert()
    } catch {
      try? await app.autoRevert()
      try? await app.asyncShutdown()
      throw error
    }
    try await app.asyncShutdown()
  }

  private func user(_ app: Application, role: UserRole = .organizer, chapter: String? = "sp") async throws -> (
    User, String
  ) {
    let user = User(appleUserIdentifier: "organizer-test-\(UUID())", role: role)
    try await user.create(on: app.db)
    if let chapter { try await OrganizerChapter(userID: user.requireID(), chapterID: chapter).create(on: app.db) }
    let token = try await app.jwt.keys.sign(
      AccessTokenPayload(
        subject: .init(value: try user.requireID().uuidString),
        expiration: .init(value: Date().addingTimeInterval(900)), issuedAt: .init(value: Date()), role: role))
    return (user, token)
  }

  private func draft(chapter: String = "sp", title: String = "Swift em produção") -> OrganizerEventDraft {
    OrganizerEventDraft(
      chapterID: chapter, title: title, startDate: Date().addingTimeInterval(3600),
      registrationURL: "https://example.com/registration",
      venue: EventVenue(name: "Academy", address: "Rua Exemplo, 100"))
  }

  private func data<Value: Encodable>(_ value: Value) throws -> Data {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return try encoder.encode(value)
  }

  private func decode<Value: Decodable>(_ type: Value.Type, _ response: TestingHTTPResponse) throws -> Value {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let string = try decoder.singleValueContainer().decode(String.self)
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      return try #require(formatter.date(from: string))
    }
    return try decoder.decode(type, from: Data(response.body.readableBytesView))
  }

  private func request(
    _ app: Application, _ method: HTTPMethod, _ path: String, token: String? = nil, includeAPIKey: Bool = true,
    body: Data? = nil
  ) async throws -> TestingHTTPResponse {
    var headers: HTTPHeaders = ["Content-Type": "application/json"]
    if includeAPIKey { headers.add(name: "X-API-Key", value: "test-key") }
    if let token { headers.bearerAuthorization = .init(token: token) }
    let result = NIOLockedValueBox<TestingHTTPResponse?>(nil)
    try await app.testing().test(
      method, path, headers: headers,
      beforeRequest: { req in
        if let body { req.body.writeBytes(body) }
      }, afterResponse: { response in result.withLockedValue { $0 = response } })
    return try #require(result.withLockedValue { $0 })
  }

  @Test("Public catalog bypasses all gates and never reveals drafts")
  func publicAccess() async throws {
    try await withApp { app in
      let draftOnly = CatalogEvent(draft: draft())
      try await draftOnly.create(on: app.db)
      let published = CatalogEvent(draft: draft(title: "Publicado"))
      published.publicSnapshot = try published.draft.publishedEvent(id: published.requireID())
      try await published.create(on: app.db)
      app.authConfiguration = configuration(attestDisabled: false)

      let response = try await request(app, .GET, "v1/screens/events", includeAPIKey: false)
      #expect(response.status == .ok)
      let catalog = try decode(ScreenDocument<EventCatalog>.self, response)
      #expect(catalog.screen == CatalogScreen.feed)
      #expect(catalog.content.chapters.count == 2)
      #expect(catalog.content.events.map(\.title) == ["Publicado"])
      let detail = try await request(app, .GET, "v1/screens/events/\(published.requireID())", includeAPIKey: false)
      #expect(detail.status == .ok)
      let hidden = try await request(app, .GET, "v1/screens/events/\(draftOnly.requireID())", includeAPIKey: false)
      #expect(hidden.status == .notFound)
      let protected = try await request(app, .GET, "v1/organizer/access", includeAPIKey: false)
      #expect(protected.status == .unauthorized)
    }
  }

  @Test("Publishing is explicit, revisions conflict, incomplete drafts remain private")
  func publishingLifecycle() async throws {
    try await withApp { app in
      let (_, token) = try await user(app)
      let create = try await request(
        app, .POST, "v1/organizer/events", token: token,
        body: data(SaveOrganizerEventRequest(draft: OrganizerEventDraft(chapterID: "sp"))))
      #expect(create.status == .created)
      let record = try decode(OrganizerEventRecord.self, create)
      #expect(UUID(uuidString: record.id) != nil)
      let invalid = try await request(
        app, .POST, "v1/organizer/events/\(record.id)/publish", token: token,
        body: data(EventRevisionRequest(revision: record.revision)))
      #expect(invalid.status == .unprocessableEntity)
      let update = try await request(
        app, .PUT, "v1/organizer/events/\(record.id)", token: token,
        body: data(SaveOrganizerEventRequest(draft: draft(), expectedRevision: record.revision)))
      #expect(update.status == .ok)
      let saved = try decode(OrganizerEventRecord.self, update)
      let publish = try await request(
        app, .POST, "v1/organizer/events/\(record.id)/publish", token: token,
        body: data(EventRevisionRequest(revision: saved.revision)))
      #expect(publish.status == .ok)
      let live = try decode(OrganizerEventRecord.self, publish)
      #expect(live.publishedAt == live.updatedAt)
      #expect(live.revision == saved.revision + 1)
      let edit = try await request(
        app, .PUT, "v1/organizer/events/\(record.id)", token: token,
        body: data(SaveOrganizerEventRequest(draft: draft(title: "Novo rascunho"), expectedRevision: live.revision)))
      #expect(edit.status == .ok)
      let edited = try decode(OrganizerEventRecord.self, edit)
      #expect(edited.updatedAt > live.updatedAt)
      let detail = try await request(app, .GET, "v1/screens/events/\(record.id)", includeAPIKey: false)
      #expect(try decode(ScreenDocument<CommunityEvent>.self, detail).content.title == "Swift em produção")
      let raw = try #require(JSONSerialization.jsonObject(with: Data(detail.body.readableBytesView)) as? [String: Any])
      #expect(raw["screen"] as? String == CatalogScreen.detail)
      #expect(raw["schemaVersion"] as? Int == CatalogScreen.version)
      let content = try #require(raw["content"] as? [String: Any])
      let timestamp = try #require(content["startDate"] as? String)
      #expect(timestamp.contains("T") && timestamp.contains(".") && timestamp.hasSuffix("Z"))
      #expect(content["endDate"] == nil)
      // Optional export lets an external native-codec harness consume real HTTP bytes
      // without making the server package depend on the Apple networking package.
      if let output = Environment.get("ORGANIZER_CONTRACT_OUTPUT"), !output.isEmpty {
        let directory = URL(fileURLWithPath: output, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let feed = try await request(app, .GET, "v1/screens/events", includeAPIKey: false)
        try Data(feed.body.readableBytesView).write(to: directory.appendingPathComponent("catalog.json"))
        try Data(detail.body.readableBytesView).write(to: directory.appendingPathComponent("event.json"))
      }
      let stale = try await request(
        app, .POST, "v1/organizer/events/\(record.id)/publish", token: token,
        body: data(EventRevisionRequest(revision: live.revision)))
      #expect(stale.status == .conflict)
    }
  }

  @Test("Chapter boundaries and current database roles override stale bearer claims")
  func authorizationAndRevocation() async throws {
    try await withApp { app in
      let (organizer, token) = try await user(app)
      let foreign = CatalogEvent(draft: draft(chapter: "rj"))
      try await foreign.create(on: app.db)
      let crossCreate = try await request(
        app, .POST, "v1/organizer/events", token: token,
        body: data(SaveOrganizerEventRequest(draft: draft(chapter: "rj"))))
      #expect(crossCreate.status == .forbidden)
      let crossUpdate = try await request(
        app, .PUT, "v1/organizer/events/\(foreign.requireID())", token: token,
        body: data(SaveOrganizerEventRequest(draft: draft(), expectedRevision: 1)))
      #expect(crossUpdate.status == .forbidden)
      let crossPublish = try await request(
        app, .POST, "v1/organizer/events/\(foreign.requireID())/publish", token: token,
        body: data(EventRevisionRequest(revision: 1)))
      #expect(crossPublish.status == .forbidden)
      #expect(
        try decode([OrganizerEventRecord].self, await request(app, .GET, "v1/organizer/events", token: token)).isEmpty)

      let own = CatalogEvent(draft: draft())
      try await own.create(on: app.db)
      try await OrganizerChapter.query(on: app.db).filter(\.$userID == organizer.requireID()).delete()
      let revokedChapter = try await request(
        app, .POST, "v1/organizer/events/\(own.requireID())/publish", token: token,
        body: data(EventRevisionRequest(revision: 1)))
      #expect(revokedChapter.status == .forbidden)
      try await OrganizerChapter(userID: organizer.requireID(), chapterID: "sp").create(on: app.db)
      organizer.role = .user
      try await organizer.update(on: app.db)
      let revokedRole = try await request(app, .GET, "v1/organizer/events", token: token)
      #expect(revokedRole.status == .forbidden)
      let deniedPublish = try await request(
        app, .POST, "v1/organizer/events/\(own.requireID())/publish", token: token,
        body: data(EventRevisionRequest(revision: 1)))
      #expect(deniedPublish.status == .forbidden)
      #expect(
        try decode(OrganizerAccess.self, await request(app, .GET, "v1/organizer/access", token: token)).user.role
          == .user)
      try await organizer.delete(on: app.db)
      #expect(try await request(app, .GET, "v1/organizer/access", token: token).status == .unauthorized)
    }
  }

  @Test("Moving a draft preserves the public chapter and requires both chapter permissions until publication")
  func chapterMove() async throws {
    try await withApp { app in
      let (editor, token) = try await user(app)
      try await OrganizerChapter(userID: editor.requireID(), chapterID: "rj").create(on: app.db)
      let event = CatalogEvent(draft: draft())
      event.publicSnapshot = try event.draft.publishedEvent(id: event.requireID())
      event.publishedAt = event.updatedAt
      try await event.create(on: app.db)
      let moved = try await request(
        app, .PUT, "v1/organizer/events/\(event.requireID())", token: token,
        body: data(SaveOrganizerEventRequest(draft: draft(chapter: "rj"), expectedRevision: 1)))
      #expect(moved.status == .ok)
      let record = try decode(OrganizerEventRecord.self, moved)
      let publicBefore = try await request(app, .GET, "v1/screens/events", includeAPIKey: false)
      let catalog = try decode(ScreenDocument<EventCatalog>.self, publicBefore).content
      #expect(catalog.events.first?.chapterID == "sp")
      #expect(catalog.chapters.map(\.id).contains("sp"))
      try await OrganizerChapter.query(on: app.db).filter(\.$userID == editor.requireID()).filter(\.$chapterID == "sp")
        .delete()
      let denied = try await request(
        app, .POST, "v1/organizer/events/\(record.id)/publish", token: token,
        body: data(EventRevisionRequest(revision: record.revision)))
      #expect(denied.status == .forbidden)
      let listed = try await request(app, .GET, "v1/organizer/events", token: token)
      #expect(try decode([OrganizerEventRecord].self, listed).isEmpty)
      try await OrganizerChapter(userID: editor.requireID(), chapterID: "sp").create(on: app.db)
      let published = try await request(
        app, .POST, "v1/organizer/events/\(record.id)/publish", token: token,
        body: data(EventRevisionRequest(revision: record.revision)))
      #expect(published.status == .ok)
      let detail = try await request(app, .GET, "v1/screens/events/\(record.id)", includeAPIKey: false)
      #expect(try decode(ScreenDocument<CommunityEvent>.self, detail).content.chapterID == "rj")
    }
  }

  @Test("An authenticated Mac-style client can read its account and publish without attestation headers")
  func identityWithoutDeviceAttestation() async throws {
    try await withApp { app in
      // Keep verification enabled. A server-issued bearer token represents the verified
      // Apple identity; this test exercises the real identity/role gates after sign-in.
      app.authConfiguration = configuration(attestDisabled: false)
      let (organizer, token) = try await user(app)
      let account = try await request(app, .GET, "me", token: token)
      #expect(account.status == .ok)
      #expect(try account.content.decode(UserDTO.self).id == organizer.requireID())
      let created = try await request(
        app, .POST, "v1/organizer/events", token: token,
        body: data(SaveOrganizerEventRequest(draft: draft())))
      #expect(created.status == .created)
      let event = try decode(OrganizerEventRecord.self, created)
      let published = try await request(
        app, .POST, "v1/organizer/events/\(event.id)/publish", token: token,
        body: data(EventRevisionRequest(revision: event.revision)))
      #expect(published.status == .ok)
      let anonymous = try await request(app, .GET, "v1/organizer/events")
      #expect(anonymous.status == .unauthorized)
      let missingKey = try await request(app, .GET, "me", token: token, includeAPIKey: false)
      #expect(missingKey.status == .unauthorized)
      let requiredAttestation = try await request(app, .POST, "scrape", token: token)
      #expect(requiredAttestation.status == .unauthorized)
    }
  }

  @Test("Global admins manage every chapter without assignments; concurrent edits have one winner")
  func adminAndConcurrentEdits() async throws {
    try await withApp { app in
      let (_, token) = try await user(app, role: .admin, chapter: nil)
      let access = try decode(OrganizerAccess.self, await request(app, .GET, "v1/organizer/access", token: token))
      #expect(access.chapters.count == 2)
      let response = try await request(
        app, .POST, "v1/organizer/events", token: token,
        body: data(SaveOrganizerEventRequest(draft: draft(chapter: "rj"))))
      #expect(response.status == .created)
      let event = try decode(OrganizerEventRecord.self, response)
      let body = try data(
        SaveOrganizerEventRequest(
          draft: draft(chapter: "rj", title: "Edição simultânea"), expectedRevision: event.revision))
      async let first = request(app, .PUT, "v1/organizer/events/\(event.id)", token: token, body: body)
      async let second = request(app, .PUT, "v1/organizer/events/\(event.id)", token: token, body: body)
      let statuses = try await [first.status, second.status]
      #expect(statuses.filter { $0 == .ok }.count == 1)
      #expect(statuses.filter { $0 == .conflict }.count == 1)
    }
  }
}
