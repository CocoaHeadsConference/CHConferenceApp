import Foundation

/// The public catalog contract, independent of storage and platform UI.
public struct ChapterSummary: Codable, Hashable, Identifiable, Sendable {
  public let id: String
  public var name: String
  public var region: String?

  public init(id: String, name: String, region: String? = nil) {
    self.id = id
    self.name = name
    self.region = region
  }
}

public enum EventFormat: String, Codable, Sendable {
  case inPerson, online, hybrid
}

public struct EventVenue: Codable, Hashable, Sendable {
  public var name: String
  public var address: String
  public var latitude: Double?
  public var longitude: Double?
  public var arrivalInstructions: String?

  public init(
    name: String, address: String, latitude: Double? = nil, longitude: Double? = nil,
    arrivalInstructions: String? = nil
  ) {
    self.name = name
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.arrivalInstructions = arrivalInstructions
  }
}

public struct EventTalk: Codable, Hashable, Identifiable, Sendable {
  public let id: String
  public var title: String
  public var speakerName: String
  public var speakerRole: String?
  public var speakerImageURL: URL?

  public init(
    id: String, title: String, speakerName: String, speakerRole: String? = nil,
    speakerImageURL: URL? = nil
  ) {
    self.id = id
    self.title = title
    self.speakerName = speakerName
    self.speakerRole = speakerRole
    self.speakerImageURL = speakerImageURL
  }
}

public struct EventLink: Codable, Hashable, Identifiable, Sendable {
  public let id: String
  public var title: String
  public var url: URL

  public init(id: String, title: String, url: URL) {
    self.id = id
    self.title = title
    self.url = url
  }
}

public enum EventPhase: Sendable {
  case upcoming, ongoing, endedToday, past
}

public struct CommunityEvent: Codable, Hashable, Identifiable, Sendable {
  public let id: String
  public var chapterID: String
  public var title: String
  public var edition: String?
  public var startDate: Date
  public var endDate: Date?
  public var timezoneID: String
  public var summary: String
  public var registrationURL: URL
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
    id: String, chapterID: String, title: String, edition: String? = nil,
    startDate: Date, endDate: Date? = nil, timezoneID: String = "America/Sao_Paulo",
    summary: String, registrationURL: URL, shareURL: URL? = nil,
    format: EventFormat = .inPerson, venue: EventVenue? = nil, onlineURL: URL? = nil,
    imageURL: URL? = nil, talks: [EventTalk] = [], links: [EventLink] = [],
    qaSessionID: String? = nil, isFeatured: Bool = false
  ) {
    self.id = id
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

  public var timeZone: TimeZone { TimeZone(identifier: timezoneID) ?? TimeZone(secondsFromGMT: 0)! }

  /// Events leave Upcoming at midnight after their final day, in the event's timezone.
  /// Without an end time, the start date determines the final day.
  public var archiveDate: Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate ?? startDate))!
  }

  public func phase(at date: Date) -> EventPhase {
    if date < startDate { return .upcoming }
    if date < (endDate ?? archiveDate) { return .ongoing }
    if date < archiveDate { return .endedToday }
    return .past
  }
}

public struct EventCatalog: Codable, Sendable {
  public var chapters: [ChapterSummary]
  public var events: [CommunityEvent]
  public var features: [CatalogFeature]

  public init(chapters: [ChapterSummary], events: [CommunityEvent], features: [CatalogFeature] = []) {
    self.chapters = chapters
    self.events = events
    self.features = features
  }

  private enum CodingKeys: String, CodingKey {
    case chapters, events, features
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    chapters = try container.decode([ChapterSummary].self, forKey: .chapters)
    events = try container.decode([CommunityEvent].self, forKey: .events)
    // Earlier catalog documents and cached screens have no editorial-content field.
    features = try container.decodeIfPresent([CatalogFeature].self, forKey: .features) ?? []
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(chapters, forKey: .chapters)
    try container.encode(events, forKey: .events)
    try container.encode(features, forKey: .features)
  }
}

/// Fixed native screens today; an explicit envelope allows future screen versions.
public struct ScreenDocument<Content: Codable & Sendable>: Codable, Sendable {
  public var schemaVersion: Int
  public var screen: String
  public var content: Content

  public init(schemaVersion: Int = 1, screen: String, content: Content) {
    self.schemaVersion = schemaVersion
    self.screen = screen
    self.content = content
  }
}

public enum CatalogScreen {
  public static let version = 1
  public static let feed = "eventFeed"
  public static let detail = "eventDetail"
}
