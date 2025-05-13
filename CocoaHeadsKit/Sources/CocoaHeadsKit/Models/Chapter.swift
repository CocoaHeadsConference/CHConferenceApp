//
//  Chapter.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/1/25.
//

import CloudKit
import Foundation

// TODO: Move to a separate package, and then rework entirely for a server-driven UI approach
struct Chapter: Identifiable, Sendable {
  var id: UUID
  let title: String
  var events: [Event]
}

extension Chapter: Equatable {
  static func == (lhs: Chapter, rhs: Chapter) -> Bool {
    lhs.id == rhs.id
  }
}

public struct Event: Hashable, Identifiable, Sendable {
  public var id: UUID
  var title: String
  var address: String
  var location: CLLocation
  var date: Date
  var endDate: Date
  var rsvpURL: URL
  var page: String
  var image: Data?
}

extension Event {
  public static var mock: Self {
    Event(
      id: UUID(),
      title: "65º CocoaHeads SP @ Apple Developer Academy Mackenzie",
      address: "av. paulista, 1100, SÃO PAULO, SP",
      location: .init(latitude: 12.3456, longitude: 12.3456),
      date: .now,
      endDate: .now.advanced(by: 3600 * 3),
      rsvpURL: URL(string: "https://meetup.com")!,
      page: "local-event-detail"
    )
  }
}

extension Chapter {
  init?(from record: CKRecord) {
    guard let id = UUID.init(uuidString: record.recordID.recordName) else {
      return nil
    }
    self.id = id
    self.events = []
    self.title = record["name"] as? String ?? ""
  }

  static func mock(_ title: String) -> Self {
    self.init(id: UUID(), title: title, events: [])
  }
}

extension Event {
  init?(from record: CKRecord) {
    guard let id = UUID.init(uuidString: record.recordID.recordName) else {
      return nil
    }

    self.id = id
    self.title = record["title"] as? String ?? ""
    self.location = record["location"] as? CLLocation ?? CLLocation(latitude: 0, longitude: 0)
    self.date = record["date"] as? Date ?? .now
    self.endDate = record["endDate"] as? Date ?? date.advanced(by: 3600 * 3)
    let urlString = (record["rsvpURL"] as? String) ?? ""
    self.rsvpURL = URL(string: urlString) ?? URL(string: "https://cocoaheads.com.br")!
    self.address = (record["address"] as? String) ?? ""
    self.page = (record["page"] as? String) ?? ""

    if let asset = record["imageAsset"] as? CKAsset,
      let fileURL = asset.fileURL,
      let data = try? Data(contentsOf: fileURL)
    {
      image = data
    }
  }
}
