import CocoaHeadsCore
import Foundation
import Testing

@testable import CocoaHeadsNetworking

struct OrganizerRepositoryTests {
  private let instant = Date(timeIntervalSince1970: 1_789_400_000)

  private func draft(chapterID: String = "sao-paulo") -> OrganizerEventDraft {
    OrganizerEventDraft(
      chapterID: chapterID, title: "Novo encontro", startDate: instant,
      summary: "Uma conversa com a comunidade", registrationURL: "https://example.com/inscricao",
      format: .online, onlineURL: URL(string: "https://example.com/ao-vivo"))
  }

  @Test("Saving is private; publishing updates the same mock feed and detail without HTTP")
  func publishedEventsReachAttendees() async throws {
    let store = MockOrganizerStore(now: { instant })
    let account = AccountClient(configuration: .init(environment: .mock), apiKey: "", transport: NoHTTP())
    _ = try await account.signInMock(role: .organizer)
    let organizer = OrganizerRepository(account: account, mockStore: store)
    let cache = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: cache) }
    let attendee = EventRepository(
      configuration: .init(environment: .mock), transport: NoHTTP(), cacheDirectory: cache,
      now: { instant }, mockDelay: .zero, mockOrganizerStore: store)

    let saved = try await organizer.save(draft: draft())
    #expect(try await attendee.catalog().content.events.contains { $0.id == saved.id } == false)
    let published = try await organizer.publish(saved)
    #expect(published.publishedAt != nil)
    #expect(try await attendee.catalog().content.events.contains { $0.id == saved.id })
    #expect(try await attendee.event(id: saved.id).content.title == "Novo encontro")
    #expect(await attendee.cachedEvent(id: saved.id)?.content.title == "Novo encontro")

    var changes = published.draft
    changes.title = "Novo título ainda em revisão"
    let updated = try await organizer.save(draft: changes, replacing: published)
    #expect(try await attendee.event(id: saved.id).content.title == "Novo encontro")
    _ = try await organizer.publish(updated)
    #expect(try await attendee.event(id: saved.id).content.title == changes.title)
  }

  @Test("Mock roles enforce chapter boundaries, and attendees cannot save")
  func previewPermissions() async throws {
    let store = MockOrganizerStore(now: { instant })
    let organizer = UserDTO(id: UUID(), role: .organizer)
    let admin = UserDTO(id: UUID(), role: .admin)
    let attendee = UserDTO(id: UUID(), role: .user)
    #expect(await store.access(user: organizer).chapters.map(\.id) == ["sao-paulo"])
    await #expect(throws: OrganizerValidationError.self) {
      _ = try await store.save(draft: draft(chapterID: "curitiba"), replacing: nil, user: organizer)
    }
    await #expect(throws: OrganizerValidationError.self) {
      _ = try await store.save(draft: draft(), replacing: nil, user: attendee)
    }
    let saved = try await store.save(draft: draft(chapterID: "curitiba"), replacing: nil, user: admin)
    #expect(saved.draft.chapterID == "curitiba")
  }

  @Test("Incomplete drafts cannot publish; stale revisions cannot overwrite changes")
  func draftAndConflictProtection() async throws {
    let store = MockOrganizerStore(now: { instant })
    let user = UserDTO(id: UUID(), role: .admin)
    let incomplete = try await store.save(draft: .init(chapterID: "sao-paulo"), replacing: nil, user: user)
    await #expect(throws: OrganizerValidationError.self) { _ = try await store.publish(incomplete, user: user) }
    let updated = try await store.save(draft: draft(), replacing: incomplete, user: user)
    await #expect(throws: OrganizerValidationError.self) {
      _ = try await store.save(draft: draft(), replacing: incomplete, user: user)
    }
    await #expect(throws: OrganizerValidationError.self) { _ = try await store.publish(incomplete, user: user) }
    _ = try await store.publish(updated, user: user)
  }

  @Test("Local mock drafts and published snapshots survive relaunch")
  func persistedPreview() async throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    let file = directory.appending(path: "organizer.json")
    defer { try? FileManager.default.removeItem(at: directory) }
    let user = UserDTO(id: UUID(), role: .admin)
    let initial = MockOrganizerStore(storageURL: file, now: { instant })
    let record = try await initial.save(draft: draft(), replacing: nil, user: user)
    _ = try await initial.publish(record, user: user)
    let restored = MockOrganizerStore(storageURL: file, now: { instant })
    #expect(await restored.catalog().events.contains { $0.id == record.id })
    #expect(try await restored.events(user: user).contains { $0.id == record.id })
  }

  @Test("A draft chapter move cannot give another organizer control of a published event")
  func unpublishedChapterMove() async throws {
    let store = MockOrganizerStore(now: { instant })
    let admin = UserDTO(id: UUID(), role: .admin)
    let organizer = UserDTO(id: UUID(), role: .organizer)
    let rio = try #require(await store.events(user: admin).first { $0.id == "demo-rio-today" })
    var movedDraft = rio.draft
    movedDraft.chapterID = "sao-paulo"
    let moved = try await store.save(draft: movedDraft, replacing: rio, user: admin)
    #expect(try await store.events(user: organizer).contains { $0.id == moved.id } == false)
    await #expect(throws: OrganizerValidationError.self) { _ = try await store.publish(moved, user: organizer) }
    #expect(await store.catalog().events.first { $0.id == moved.id }?.chapterID == "rio-de-janeiro")
  }
}

private struct NoHTTP: EventHTTPTransport {
  func data(for request: URLRequest) async throws -> EventHTTPResponse {
    Issue.record("Mock organizer flow attempted HTTP: \(request.httpMethod ?? "")")
    throw URLError(.notConnectedToInternet)
  }
}
