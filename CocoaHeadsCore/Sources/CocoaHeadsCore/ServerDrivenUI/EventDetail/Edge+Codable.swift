//
//  Edge+Codable.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/7/25.
//

import SwiftUI

// TODO: Move this to `Common`

extension Edge.Set: @retroactive Codable {
  private enum CodingKeys: String, CodingKey {
    case top, leading, bottom, trailing, all, horizontal, vertical
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var edges: Edge.Set = []

    if try container.decodeIfPresent(Bool.self, forKey: .top) == true {
      edges.insert(.top)
    }
    if try container.decodeIfPresent(Bool.self, forKey: .leading) == true {
      edges.insert(.leading)
    }
    if try container.decodeIfPresent(Bool.self, forKey: .bottom) == true {
      edges.insert(.bottom)
    }
    if try container.decodeIfPresent(Bool.self, forKey: .trailing) == true {
      edges.insert(.trailing)
    }
    if try container.decodeIfPresent(Bool.self, forKey: .all) == true {
      edges = .all
    }
    if try container.decodeIfPresent(Bool.self, forKey: .horizontal) == true {
      edges.insert(.horizontal)
    }
    if try container.decodeIfPresent(Bool.self, forKey: .vertical) == true {
      edges.insert(.vertical)
    }

    self = edges
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.contains(.top), forKey: .top)
    try container.encode(self.contains(.leading), forKey: .leading)
    try container.encode(self.contains(.bottom), forKey: .bottom)
    try container.encode(self.contains(.trailing), forKey: .trailing)
    try container.encode(self == .all, forKey: .all)
    try container.encode(self.contains(.horizontal), forKey: .horizontal)
    try container.encode(self.contains(.vertical), forKey: .vertical)
  }
}
