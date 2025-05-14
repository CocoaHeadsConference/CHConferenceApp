//
//  UI.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

// TODO: We need stable identifiers that don't rely on inner values

indirect enum UI: Codable, Identifiable, Sendable, Equatable {
  case home(HomeUI)
  case eventDetail([EventDetailUI])

  var id: String {
    switch self {
    case .home(let homeUI):
      "page-ui-home" + homeUI.id
    case .eventDetail(let eventDetailUI):
      "page-ui-event-detail" + String(eventDetailUI.map(\.id).joined())
    }
  }

  var description: String {
    switch self {
    case .home:
      "Home"
    case .eventDetail:
      "Event Detail"
    }
  }

  static func == (lhs: UI, rhs: UI) -> Bool {
    lhs.id == rhs.id
  }
}
