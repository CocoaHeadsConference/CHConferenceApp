import CocoaHeadsCore
import Foundation

/// One local store connects organizer previews to the public mock feed. It never makes network requests.
public actor MockOrganizerStore {
  private struct State: Codable {
    var records: [String: OrganizerEventRecord] = [:]
    var published: [String: CommunityEvent] = [:]
  }

  private let now: @Sendable () -> Date
  private let storageURL: URL?
  private var state: State

  public init(storageURL: URL? = nil, now: @escaping @Sendable () -> Date = { .now }) {
    self.storageURL = storageURL
    self.now = now
    if let storageURL, let data = try? Data(contentsOf: storageURL),
      let saved = try? JSONDecoder().decode(State.self, from: data)
    {
      state = saved
    } else {
      state = State()
    }
  }

  public func catalog() -> EventCatalog {
    var catalog = CatalogFixtures.catalog(now: now())
    catalog.events.removeAll { state.published[$0.id] != nil }
    catalog.events.append(contentsOf: state.published.values)
    // Keep editorial cards aligned with edited, published events too.
    catalog.features = catalog.features.map { feature in
      var feature = feature
      if case .event(let id) = feature.destination, let event = state.published[id] {
        feature.chapterID = event.chapterID
        feature.title = event.title
        feature.imageURL = event.imageURL
      }
      return feature
    }
    return catalog
  }

  public func access(user: UserDTO) -> OrganizerAccess {
    let chapters = CatalogFixtures.catalog(now: now()).chapters
    return OrganizerAccess(
      user: user,
      chapters: chapters.filter {
        user.role == .admin || (user.role == .organizer && $0.id == "sao-paulo")
      })
  }

  public func events(user: UserDTO) throws -> [OrganizerEventRecord] {
    try requireOrganizer(user)
    let allowed = Set(access(user: user).chapters.map(\.id))
    var records = state.records
    let date = now().addingTimeInterval(-86_400)
    for event in catalog().events where records[event.id] == nil {
      records[event.id] = OrganizerEventRecord(
        id: event.id, draft: .init(event: event), revision: 1, publishedAt: date, updatedAt: date)
    }
    return records.values.filter {
      allowed.contains($0.draft.chapterID)
        && (publishedEvent(id: $0.id).map { allowed.contains($0.chapterID) } ?? true)
    }
    .sorted { $0.updatedAt > $1.updatedAt }
  }

  public func save(
    draft: OrganizerEventDraft, replacing record: OrganizerEventRecord?, user: UserDTO
  ) throws -> OrganizerEventRecord {
    try authorize(draft.chapterID, user: user)
    try draft.validateForSaving()
    let current: OrganizerEventRecord?
    if let record {
      current = try events(user: user).first { $0.id == record.id }
      guard let current, current.revision == record.revision else {
        throw OrganizerValidationError(
          reason: "Este evento foi alterado. Reabra-o para carregar a versão mais recente.")
      }
      try authorize(current.draft.chapterID, user: user)
      if let published = publishedEvent(id: record.id) { try authorize(published.chapterID, user: user) }
    } else {
      current = nil
    }
    let updatedAt = max(now(), (current?.updatedAt ?? .distantPast).addingTimeInterval(0.001))
    let updated = OrganizerEventRecord(
      id: current?.id ?? UUID().uuidString.lowercased(), draft: draft,
      revision: (current?.revision ?? 0) + 1, publishedAt: current?.publishedAt, updatedAt: updatedAt)
    var next = state
    next.records[updated.id] = updated
    try persist(next)
    return updated
  }

  public func publish(_ record: OrganizerEventRecord, user: UserDTO) throws -> OrganizerEventRecord {
    try authorize(record.draft.chapterID, user: user)
    guard var current = state.records[record.id], current.revision == record.revision else {
      throw OrganizerValidationError(reason: "Este evento foi alterado. Reabra-o para carregar a versão mais recente.")
    }
    try authorize(current.draft.chapterID, user: user)
    if let published = publishedEvent(id: current.id) { try authorize(published.chapterID, user: user) }
    let event = try current.draft.publishedEvent(id: current.id)
    let date = now()
    current.publishedAt = date
    current.updatedAt = date
    current.revision += 1
    var next = state
    next.records[current.id] = current
    next.published[current.id] = event
    try persist(next)
    return current
  }

  private func authorize(_ chapterID: String, user: UserDTO) throws {
    try requireOrganizer(user)
    guard access(user: user).chapters.contains(where: { $0.id == chapterID }) else {
      throw OrganizerValidationError(reason: "Você não tem acesso à organização deste capítulo.")
    }
  }

  private func publishedEvent(id: String) -> CommunityEvent? {
    state.published[id] ?? CatalogFixtures.catalog(now: now()).events.first { $0.id == id }
  }

  private func requireOrganizer(_ user: UserDTO) throws {
    guard user.role == .organizer || user.role == .admin else {
      throw OrganizerValidationError(reason: "Um administrador precisa liberar seu acesso à organização.")
    }
  }

  private func persist(_ next: State) throws {
    if let storageURL {
      try FileManager.default.createDirectory(
        at: storageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      try JSONEncoder().encode(next).write(to: storageURL, options: .atomic)
    }
    state = next
  }
}
