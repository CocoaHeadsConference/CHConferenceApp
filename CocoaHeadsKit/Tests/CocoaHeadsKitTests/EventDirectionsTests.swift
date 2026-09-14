import CocoaHeadsCore
import Foundation
import Testing

@testable import CocoaHeadsKit

@Suite("Venue directions")
struct EventDirectionsTests {
  @Test("Every maps provider receives the supplied coordinates as the destination")
  func preciseCoordinates() throws {
    let venue = EventVenue(
      name: "Local do evento", address: "Rua Butantã, 194, São Paulo",
      latitude: -23.56916, longitude: -46.69727)
    let apple = try #require(EventDirectionsLinks.appleMapsURL(for: venue))
    let google = try #require(EventDirectionsLinks.googleMapsURL(for: venue))
    let waze = try #require(EventDirectionsLinks.wazeURL(for: venue))
    let appleQuery = try query(apple)
    let googleQuery = try query(google)
    let wazeQuery = try query(waze)

    #expect(apple.scheme == "https")
    #expect(apple.host == "maps.apple.com")
    #expect(appleQuery["daddr"] == "-23.56916,-46.69727")
    #expect(google.scheme == "comgooglemaps")
    #expect(googleQuery["daddr"] == "-23.56916,-46.69727")
    #expect(waze.scheme == "waze")
    #expect(wazeQuery["ll"] == "-23.56916,-46.69727")
    #expect(wazeQuery["navigate"] == "yes")
    #expect(appleQuery["saddr"] == nil)
    #expect(googleQuery["saddr"] == nil)
  }

  @Test("Address-only links preserve accents and query characters without fabricating coordinates")
  func addressEncoding() throws {
    let address = "Rua São João, 42 + 44 & bloco #B? portão=2"
    let venue = EventVenue(name: "Local do evento", address: "  \(address)\n")
    let apple = try #require(EventDirectionsLinks.appleMapsURL(for: venue))
    let google = try #require(EventDirectionsLinks.googleMapsURL(for: venue))
    let waze = try #require(EventDirectionsLinks.wazeURL(for: venue))
    let appleQuery = try query(apple)
    let googleQuery = try query(google)
    let wazeQuery = try query(waze)

    #expect(EventDirectionsLinks.coordinates(for: venue) == nil)
    #expect(appleQuery == ["daddr": address])
    #expect(googleQuery == ["daddr": address])
    #expect(wazeQuery == ["q": address])
    for url in [apple, google, waze] {
      #expect(url.fragment == nil)
      #expect(!url.absoluteString.contains("+"))
    }
  }

  @Test("Incomplete and invalid coordinates fall back to the supplied address")
  func invalidCoordinates() throws {
    let invalid: [(Double?, Double?)] = [
      (-23.5, nil), (nil, -46.6), (.nan, -46.6), (-23.5, .infinity),
      (91, -46.6), (-91, -46.6), (-23.5, 181), (-23.5, -181)
    ]
    for (latitude, longitude) in invalid {
      let venue = EventVenue(
        name: "Local do evento", address: "Rua das Flores, 12, Curitiba",
        latitude: latitude, longitude: longitude)
      #expect(EventDirectionsLinks.coordinates(for: venue) == nil)
      let apple = try #require(EventDirectionsLinks.appleMapsURL(for: venue))
      let google = try #require(EventDirectionsLinks.googleMapsURL(for: venue))
      let waze = try #require(EventDirectionsLinks.wazeURL(for: venue))
      #expect(try query(apple)["daddr"] == venue.address)
      #expect(try query(google)["daddr"] == venue.address)
      #expect(try query(waze)["q"] == venue.address)
    }
  }

  @Test("Zero-valued coordinates remain valid")
  func zeroCoordinates() throws {
    let venue = EventVenue(name: "Ponto informado", address: "", latitude: 0, longitude: 0)
    let coordinates = try #require(EventDirectionsLinks.coordinates(for: venue))
    #expect(coordinates.latitude == 0)
    #expect(coordinates.longitude == 0)
    let apple = try #require(EventDirectionsLinks.appleMapsURL(for: venue))
    #expect(try query(apple)["daddr"] == "0.0,0.0")
  }

  @Test("A venue name alone does not produce a guessed destination")
  func missingDestination() {
    let venue = EventVenue(name: "Apple Developer Academy", address: " \n ")
    #expect(EventDirectionsLinks.coordinates(for: venue) == nil)
    #expect(EventDirectionsLinks.appleMapsURL(for: venue) == nil)
    #expect(EventDirectionsLinks.googleMapsURL(for: venue) == nil)
    #expect(EventDirectionsLinks.wazeURL(for: venue) == nil)
  }

  private func query(_ url: URL) throws -> [String: String] {
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let items = try #require(components.queryItems)
    return try Dictionary(
      uniqueKeysWithValues: items.map { item in
        (item.name, try #require(item.value))
      })
  }
}
