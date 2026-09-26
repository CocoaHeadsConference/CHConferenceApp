import Foundation
import Testing

@testable import CocoaHeadsCore

@Suite("Independent featured content")
struct CatalogFeatureTests {
  @Test("Destination cases use explicit tags and round trip without compiler-specific enum keys")
  func destinationWireShape() throws {
    let url = try #require(URL(string: "https://example.com/comunidade"))
    let cases: [(CatalogFeature.Destination, [String: String])] = [
      (.event(id: "event-42"), ["type": "event", "eventID": "event-42"]),
      (.externalURL(url), ["type": "externalURL", "url": url.absoluteString]),
      (.placeholder(title: "Em breve"), ["type": "placeholder", "title": "Em breve"])
    ]
    for (destination, expected) in cases {
      let data = try JSONEncoder().encode(destination)
      let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: String])
      #expect(object == expected)
      #expect(try JSONDecoder().decode(CatalogFeature.Destination.self, from: data) == destination)
    }
  }

  @Test("National and chapter features preserve their identity, content, and order")
  func featureRoundTrip() throws {
    let imageURL = try #require(URL(string: "https://example.com/banner.png"))
    let catalog = EventCatalog(
      chapters: [], events: [],
      features: [
        CatalogFeature(
          id: "national", title: "CocoaHeads Brasil", subtitle: "Nossa comunidade",
          imageURL: imageURL,
          destination: .placeholder(title: "Mais novidades em breve")),
        CatalogFeature(
          id: "chapter", chapterID: "florianopolis", title: "Conheça o capítulo",
          destination: .externalURL(try #require(URL(string: "https://example.com/floripa"))))
      ])
    let decoded = try JSONDecoder().decode(EventCatalog.self, from: JSONEncoder().encode(catalog))
    #expect(decoded.features == catalog.features)
    #expect(decoded.features[0].chapterID == nil)
    #expect(decoded.features[1].chapterID == "florianopolis")
  }

  @Test("Catalogs written before independent features remain decodable")
  func legacyCatalog() throws {
    let data = Data(#"{"chapters":[],"events":[]}"#.utf8)
    let catalog = try JSONDecoder().decode(EventCatalog.self, from: data)
    #expect(catalog.features.isEmpty)
  }

  @Test("Unknown destination behavior is distinguishable from a malformed known destination")
  func unknownAndMalformedDestinations() throws {
    let future = Data(#"{"type":"video","videoID":"42"}"#.utf8)
    #expect(throws: CatalogDecodingError.unsupportedFeatureDestination("video")) {
      try JSONDecoder().decode(CatalogFeature.Destination.self, from: future)
    }
    let malformed = Data(#"{"type":"event"}"#.utf8)
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(CatalogFeature.Destination.self, from: malformed)
    }
  }
}
