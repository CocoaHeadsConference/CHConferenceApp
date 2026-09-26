import Foundation

/// Editorial content independent of an event. A nil chapterID means national content.
public struct CatalogFeature: Codable, Hashable, Identifiable, Sendable {
  public let id: String
  public var chapterID: String?
  public var title: String
  public var subtitle: String?
  public var imageURL: URL?
  public var destination: Destination

  public init(
    id: String, chapterID: String? = nil, title: String, subtitle: String? = nil,
    imageURL: URL? = nil, destination: Destination
  ) {
    self.id = id
    self.chapterID = chapterID
    self.title = title
    self.subtitle = subtitle
    self.imageURL = imageURL
    self.destination = destination
  }

  public enum Destination: Codable, Hashable, Sendable {
    case event(id: String)
    case externalURL(URL)
    case placeholder(title: String)

    private enum CodingKeys: String, CodingKey {
      case type, eventID, url, title
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let type = try container.decode(String.self, forKey: .type)
      switch type {
      case "event": self = .event(id: try container.decode(String.self, forKey: .eventID))
      case "externalURL": self = .externalURL(try container.decode(URL.self, forKey: .url))
      case "placeholder": self = .placeholder(title: try container.decode(String.self, forKey: .title))
      default: throw CatalogDecodingError.unsupportedFeatureDestination(type)
      }
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .event(let id):
        try container.encode("event", forKey: .type)
        try container.encode(id, forKey: .eventID)
      case .externalURL(let url):
        try container.encode("externalURL", forKey: .type)
        try container.encode(url, forKey: .url)
      case .placeholder(let title):
        try container.encode("placeholder", forKey: .type)
        try container.encode(title, forKey: .title)
      }
    }
  }
}

/// A recognized document contains behavior this client cannot present.
public enum CatalogDecodingError: Error, Equatable, Sendable {
  case unsupportedFeatureDestination(String)
}
