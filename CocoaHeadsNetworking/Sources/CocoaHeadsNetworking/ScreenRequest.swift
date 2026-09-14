import CocoaHeadsCore
import Foundation

/// Like Joguei's requests, each endpoint declares its response and owns its mock answer.
protocol ScreenRequest: Sendable {
  associatedtype Content: Codable & Sendable
  var screen: String { get }
  var pathComponents: [String] { get }
  func mockContent(from catalog: EventCatalog) throws -> Content
  func validate(_ content: Content) throws
}

extension ScreenRequest {
  var cacheKey: String { pathComponents.joined(separator: "/") }
}

struct CatalogRequest: ScreenRequest {
  var screen: String { CatalogScreen.feed }
  var pathComponents: [String] { ["v1", "screens", "events"] }

  func mockContent(from catalog: EventCatalog) -> EventCatalog { catalog }

  func validate(_ catalog: EventCatalog) throws {
    let chapterIDs = catalog.chapters.map(\.id)
    guard Set(chapterIDs).count == chapterIDs.count,
      catalog.chapters.allSatisfy({ !$0.id.isEmpty && !$0.name.isEmpty }),
      Set(catalog.events.map(\.id)).count == catalog.events.count,
      Set(catalog.features.map(\.id)).count == catalog.features.count
    else { throw ScreenLoadingError.invalidResponse }
    for event in catalog.events {
      guard chapterIDs.contains(event.chapterID) else { throw ScreenLoadingError.invalidResponse }
      try validateEvent(event)
    }
    let eventIDs = Set(catalog.events.map(\.id))
    for feature in catalog.features {
      guard !feature.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        !feature.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        feature.chapterID.map({ chapterIDs.contains($0) }) ?? true,
        feature.imageURL.map(isWebURL) ?? true
      else { throw ScreenLoadingError.invalidResponse }
      switch feature.destination {
      case .event(let id):
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, eventIDs.contains(id)
        else { throw ScreenLoadingError.invalidResponse }
      case .externalURL(let url):
        guard isWebURL(url) else { throw ScreenLoadingError.invalidResponse }
      case .placeholder(let title):
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { throw ScreenLoadingError.invalidResponse }
      }
    }
  }
}

struct EventRequest: ScreenRequest {
  let id: String
  var screen: String { CatalogScreen.detail }
  var pathComponents: [String] { ["v1", "screens", "events", id] }

  func mockContent(from catalog: EventCatalog) throws -> CommunityEvent {
    guard let event = catalog.events.first(where: { $0.id == id }) else {
      throw ScreenLoadingError.httpStatus(404)
    }
    return event
  }

  func validate(_ event: CommunityEvent) throws {
    guard event.id == id else { throw ScreenLoadingError.invalidResponse }
    try validateEvent(event)
  }
}

private func validateEvent(_ event: CommunityEvent) throws {
  guard !event.id.isEmpty, !event.chapterID.isEmpty, !event.title.isEmpty,
    event.startDate.timeIntervalSince1970.isFinite,
    event.endDate.map({ $0.timeIntervalSince1970.isFinite && $0 >= event.startDate }) ?? true,
    TimeZone(identifier: event.timezoneID) != nil,
    event.qaSessionID.map({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ?? true,
    isWebURL(event.registrationURL),
    [event.shareURL, event.onlineURL, event.imageURL].compactMap({ $0 }).allSatisfy(isWebURL),
    Set(event.talks.map(\.id)).count == event.talks.count,
    event.talks.allSatisfy({ !$0.id.isEmpty && ($0.speakerImageURL.map(isWebURL) ?? true) }),
    Set(event.links.map(\.id)).count == event.links.count,
    event.links.allSatisfy({ !$0.id.isEmpty && isWebURL($0.url) })
  else { throw ScreenLoadingError.invalidResponse }
  if let venue = event.venue {
    switch (venue.latitude, venue.longitude) {
    case (nil, nil): break
    case (.some(let latitude), .some(let longitude)):
      guard (-90...90).contains(latitude), (-180...180).contains(longitude) else {
        throw ScreenLoadingError.invalidResponse
      }
    default: throw ScreenLoadingError.invalidResponse
    }
  }
}

func isWebURL(_ url: URL) -> Bool {
  ["https", "http"].contains(url.scheme?.lowercased() ?? "") && !(url.host ?? "").isEmpty
}
