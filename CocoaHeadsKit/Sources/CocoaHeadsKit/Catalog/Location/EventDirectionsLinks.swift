import CocoaHeadsCore
import Foundation

/// Provider URLs use the supplied venue destination. Location lookup belongs to the selected maps app.
enum EventDirectionsLinks {
  struct Coordinates: Hashable, Sendable {
    let latitude: Double
    let longitude: Double

    var queryValue: String { "\(latitude),\(longitude)" }
  }

  static let googleMapsAvailabilityURL = URL(string: "comgooglemaps://")
  static let wazeAvailabilityURL = URL(string: "waze://")

  static func coordinates(for venue: EventVenue) -> Coordinates? {
    guard let latitude = venue.latitude, let longitude = venue.longitude,
      latitude.isFinite, longitude.isFinite,
      (-90...90).contains(latitude), (-180...180).contains(longitude)
    else { return nil }
    return Coordinates(latitude: latitude, longitude: longitude)
  }

  static func appleMapsURL(for venue: EventVenue) -> URL? {
    guard let destination = destination(for: venue) else { return nil }
    return url(
      scheme: "https", host: "maps.apple.com",
      items: [URLQueryItem(name: "daddr", value: destination)])
  }

  // https://developers.google.com/maps/documentation/urls/ios-urlscheme
  static func googleMapsURL(for venue: EventVenue) -> URL? {
    guard let destination = destination(for: venue) else { return nil }
    return url(scheme: "comgooglemaps", items: [URLQueryItem(name: "daddr", value: destination)])
  }

  // https://developers.google.com/waze/deeplinks
  static func wazeURL(for venue: EventVenue) -> URL? {
    if let coordinates = coordinates(for: venue) {
      return url(
        scheme: "waze",
        items: [
          URLQueryItem(name: "ll", value: coordinates.queryValue),
          URLQueryItem(name: "navigate", value: "yes")
        ])
    }
    guard let address = address(for: venue) else { return nil }
    // Without a precise destination, let the attendee choose the matching address in Waze.
    return url(scheme: "waze", items: [URLQueryItem(name: "q", value: address)])
  }

  static func address(for venue: EventVenue) -> String? {
    let address = venue.address.trimmingCharacters(in: .whitespacesAndNewlines)
    return address.isEmpty ? nil : address
  }

  private static func destination(for venue: EventVenue) -> String? {
    coordinates(for: venue)?.queryValue ?? address(for: venue)
  }

  private static func url(scheme: String, host: String = "", items: [URLQueryItem]) -> URL? {
    var components = URLComponents()
    components.scheme = scheme
    components.host = host
    components.queryItems = items
    // Some maps providers interpret a literal '+' as a space in query parameters.
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    return components.url
  }
}
