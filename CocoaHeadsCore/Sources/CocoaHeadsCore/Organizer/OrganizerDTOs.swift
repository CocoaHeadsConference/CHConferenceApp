import Foundation

public struct OrganizerAccess: Codable, Equatable, Sendable {
  public var user: UserDTO
  public var chapters: [ChapterSummary]

  public init(user: UserDTO, chapters: [ChapterSummary]) {
    self.user = user
    self.chapters = chapters
  }
}

/// Incomplete editing state. Only `publishedEvent(id:)` can turn a draft into public content.
public struct OrganizerEventDraft: Codable, Hashable, Sendable {
  public var chapterID: String
  public var title: String
  public var edition: String?
  public var startDate: Date?
  public var endDate: Date?
  public var timezoneID: String
  public var summary: String
  public var registrationURL: String
  public var shareURL: URL?
  public var format: EventFormat
  public var venue: EventVenue?
  public var onlineURL: URL?
  public var imageURL: URL?
  public var talks: [EventTalk]
  public var links: [EventLink]
  public var qaSessionID: String?
  public var isFeatured: Bool

  public init(
    chapterID: String = "", title: String = "", edition: String? = nil,
    startDate: Date? = nil, endDate: Date? = nil, timezoneID: String = "America/Sao_Paulo",
    summary: String = "", registrationURL: String = "", shareURL: URL? = nil,
    format: EventFormat = .inPerson, venue: EventVenue? = nil, onlineURL: URL? = nil,
    imageURL: URL? = nil, talks: [EventTalk] = [], links: [EventLink] = [],
    qaSessionID: String? = nil, isFeatured: Bool = false
  ) {
    self.chapterID = chapterID
    self.title = title
    self.edition = edition
    self.startDate = startDate
    self.endDate = endDate
    self.timezoneID = timezoneID
    self.summary = summary
    self.registrationURL = registrationURL
    self.shareURL = shareURL
    self.format = format
    self.venue = venue
    self.onlineURL = onlineURL
    self.imageURL = imageURL
    self.talks = talks
    self.links = links
    self.qaSessionID = qaSessionID
    self.isFeatured = isFeatured
  }

  public init(event: CommunityEvent) {
    self.init(
      chapterID: event.chapterID, title: event.title, edition: event.edition,
      startDate: event.startDate, endDate: event.endDate, timezoneID: event.timezoneID,
      summary: event.summary, registrationURL: event.registrationURL.absoluteString,
      shareURL: event.shareURL, format: event.format, venue: event.venue,
      onlineURL: event.onlineURL, imageURL: event.imageURL, talks: event.talks,
      links: event.links, qaSessionID: event.qaSessionID, isFeatured: event.isFeatured)
  }

  public func validateForSaving() throws {
    let bounded =
      title.count <= 240 && chapterID.count <= 100 && summary.count <= 20_000
      && registrationURL.count <= 4_096 && (edition?.count ?? 0) <= 100
      && timezoneID.count <= 100 && (qaSessionID?.count ?? 0) <= 200
      && talks.count <= 100 && links.count <= 50
    try require(bounded, "O evento excede o limite de texto, palestras ou links.")
    for url in [shareURL, onlineURL, imageURL].compactMap({ $0 }) {
      try require(url.absoluteString.count <= 4_096, "Um dos links é muito longo.")
    }
    if let venue {
      try require(
        venue.name.count <= 240 && venue.address.count <= 1_000 && (venue.arrivalInstructions?.count ?? 0) <= 10_000,
        "As informações do local excedem o limite de texto.")
    }
    for talk in talks {
      try require(
        talk.id.count <= 200 && talk.title.count <= 240 && talk.speakerName.count <= 240
          && (talk.speakerRole?.count ?? 0) <= 240 && (talk.speakerImageURL?.absoluteString.count ?? 0) <= 4_096,
        "Uma palestra excede o limite de texto.")
    }
    for link in links {
      try require(
        link.id.count <= 200 && link.title.count <= 240 && link.url.absoluteString.count <= 4_096,
        "Um link excede o limite de texto.")
    }
  }

  public func publishedEvent(id: String) throws -> CommunityEvent {
    try validateForSaving()
    try require(!trimmed(id).isEmpty, "O evento precisa de um identificador válido.")
    if let qaSessionID {
      try require(!trimmed(qaSessionID).isEmpty, "Informe um identificador de perguntas válido ou remova esse campo.")
    }
    try require(!trimmed(title).isEmpty, "Informe o título do evento.")
    try require(!trimmed(chapterID).isEmpty, "Escolha o capítulo do evento.")
    guard let startDate else { throw OrganizerValidationError(reason: "Informe quando o evento começa.") }
    try require(startDate.timeIntervalSince1970.isFinite, "Informe uma data de início válida.")
    try require(TimeZone(identifier: timezoneID) != nil, "Escolha um fuso horário válido.")
    if let endDate {
      try require(
        endDate.timeIntervalSince1970.isFinite && endDate > startDate, "O encerramento deve ser depois do início.")
    }
    guard let registration = URL(string: trimmed(registrationURL)), Self.isWebURL(registration) else {
      throw OrganizerValidationError(reason: "Informe o link de inscrição completo, começando com https:// ou http://.")
    }
    for url in [shareURL, onlineURL, imageURL].compactMap({ $0 }) {
      try require(Self.isWebURL(url), "Os links do evento devem começar com https:// ou http://.")
    }
    if format != .online {
      guard let venue else { throw OrganizerValidationError(reason: "Informe o local do encontro.") }
      try require(
        !trimmed(venue.name).isEmpty && !trimmed(venue.address).isEmpty,
        "Informe o nome e o endereço completo do local.")
    }
    if format != .inPerson {
      try require(onlineURL != nil, "Informe o link da transmissão online.")
    }
    if let venue {
      try require((venue.latitude == nil) == (venue.longitude == nil), "Informe latitude e longitude juntas.")
      if let latitude = venue.latitude, let longitude = venue.longitude {
        try require(
          latitude.isFinite && longitude.isFinite && (-90...90).contains(latitude) && (-180...180).contains(longitude),
          "Confira as coordenadas do local.")
      }
    }
    try require(Set(talks.map(\.id)).count == talks.count, "As palestras precisam ter identificadores diferentes.")
    for talk in talks {
      try require(
        !trimmed(talk.id).isEmpty && !trimmed(talk.title).isEmpty && !trimmed(talk.speakerName).isEmpty,
        "Complete o título e o nome de quem apresenta cada palestra.")
      if let image = talk.speakerImageURL {
        try require(Self.isWebURL(image), "Confira o link da foto de quem apresenta.")
      }
    }
    try require(Set(links.map(\.id)).count == links.count, "Os links precisam ter identificadores diferentes.")
    for link in links {
      try require(
        !trimmed(link.id).isEmpty && !trimmed(link.title).isEmpty && Self.isWebURL(link.url),
        "Complete o título e o endereço de cada link.")
    }
    return CommunityEvent(
      id: id, chapterID: chapterID, title: trimmed(title), edition: edition,
      startDate: startDate, endDate: endDate, timezoneID: timezoneID,
      summary: summary, registrationURL: registration, shareURL: shareURL,
      format: format, venue: venue, onlineURL: onlineURL, imageURL: imageURL,
      talks: talks, links: links, qaSessionID: qaSessionID, isFeatured: isFeatured)
  }

  private static func isWebURL(_ url: URL) -> Bool {
    ["https", "http"].contains(url.scheme?.lowercased() ?? "")
      && !(url.host?.isEmpty ?? true) && url.user == nil && url.password == nil
  }

  private func trimmed(_ text: String) -> String {
    text.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func require(_ condition: Bool, _ reason: String) throws {
    if !condition { throw OrganizerValidationError(reason: reason) }
  }
}

public struct OrganizerValidationError: Error, LocalizedError, Equatable, Sendable {
  public let reason: String
  public var errorDescription: String? { reason }
  public init(reason: String) { self.reason = reason }
}

public struct OrganizerEventRecord: Codable, Hashable, Identifiable, Sendable {
  public let id: String
  public var draft: OrganizerEventDraft
  public var revision: Int
  public var publishedAt: Date?
  public var updatedAt: Date

  public init(id: String, draft: OrganizerEventDraft, revision: Int, publishedAt: Date? = nil, updatedAt: Date) {
    self.id = id
    self.draft = draft
    self.revision = revision
    self.publishedAt = publishedAt
    self.updatedAt = updatedAt
  }
}

public struct SaveOrganizerEventRequest: Codable, Sendable {
  public var draft: OrganizerEventDraft
  public var expectedRevision: Int?
  public init(draft: OrganizerEventDraft, expectedRevision: Int? = nil) {
    self.draft = draft
    self.expectedRevision = expectedRevision
  }
}

public struct EventRevisionRequest: Codable, Sendable {
  public var revision: Int
  public init(revision: Int) { self.revision = revision }
}
