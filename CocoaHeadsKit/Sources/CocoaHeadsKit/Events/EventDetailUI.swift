//
//  EventDetailUI.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/7/25.
//

import SwiftUI

public indirect enum EventDetailUI: Codable, Sendable {
  case card(title: String?, edges: Edge.Set, insetBy: CGFloat?, ui: [EventDetailUI])
  case carousel(ui: [EventDetailUI])
  // TODO: Action -> openURL instead of direct URL
  case callToAction(title: String, url: URL, systemImage: String?)
  case caption(text: String)
  case debug(EventDetailUI)
  case details(title: String, remoteImage: URL?, cloudKitImageID: UUID?, shareURL: URL)
  case divider
  case empty
  case link(URL, title: String?)
  case map(address: String, lat: Double, lng: Double)
  case subtitle(String)
  case text(String)
  case titleSubtitle(title: String, subtitle: String, systemImage: String)
  case vstack(ui: [EventDetailUI])
}

// MARK: Identifiable

extension EventDetailUI: Identifiable {
  public var id: String {
    switch self {
    case .card(let title, let edges, let insetBy, let ui):
      "card-\(title ?? "nil")-\(edges.rawValue)-\(insetBy ?? 0)-\(ui.map(\.id).joined(separator: ","))"
    case .carousel(let ui):
      "carousel-\(ui.map(\.id).joined(separator: ","))"
    case .callToAction(let title, let url, let systemImage):
      "callToAction-\(title)-\(url.absoluteString)-\(systemImage ?? "nil")"
    case .caption(let text):
      "caption-\(text)"
    case .debug(let ui):
      "debug-\(ui.id)"
    case .details(title: let title, remoteImage: let remote, cloudKitImageID: let ckImage, shareURL: let share):
      "details-\(title)-\(remote?.hashValue ?? 0)-\(ckImage?.hashValue ?? 0)-\(share.hashValue)"
    case .divider:
      "divider" + UUID().uuidString
    case .empty:
      ""
    case .link(let url, let title):
      "link-\(url.absoluteString)-\(title ?? "nil")"
    case .map(address: let addr, lat: let lat, lng: let lng):
      "map-\(addr)-\(lat)-\(lng)"
    case .subtitle(let text):
      "subtitle-\(text)"
    case .text(let text):
      "text-\(text)"
    case .titleSubtitle(let title, let subtitle, let systemImage):
      "titleSubtitle-\(title)-\(subtitle)-\(systemImage)"
    case .vstack(let ui):
      "vstack-\(ui.map(\.id).joined(separator: ","))"
    }
  }
}

extension EventDetailUI {
  // TODO: This should be part of a base set of server driven UIs
  // eg.: .sdui(.debug(.eventDetail(self)))
  func debug() -> EventDetailUI {
    .debug(self)
  }
}

// MARK: Helper methods
extension EventDetailUI {
  public static func card(title: String?, ui: [EventDetailUI]) -> EventDetailUI {
    return .card(title: title, edges: .all, insetBy: nil, ui: ui)
  }

  static func callToAction(title: String, url: URL) -> EventDetailUI {
    return .callToAction(title: title, url: url, systemImage: nil)
  }

  static func link(_ url: URL) -> EventDetailUI {
    return .link(url, title: nil)
  }

  static func speaker(name: String?, talk: String?) -> EventDetailUI {
    var string = ""
    if let name {
      string.append("**\(name)**\n")
    }
    if let talk {
      string.append("\(talk)")
    }
    return .subtitle(string)
  }
}
