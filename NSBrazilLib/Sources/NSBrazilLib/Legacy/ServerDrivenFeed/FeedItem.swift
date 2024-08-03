//
//  FeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

public class FeedItem: Codable, Identifiable {
    public let id = UUID()
    public let type: FeedItemType

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(FeedItemType.self, forKey: .type)
    }

    public init(type: FeedItemType) {
        self.type = type
    }
}

extension FeedItem {
  static var mock: HomeFeed {
    let url = Bundle.main.url(forResource: "2019", withExtension: "json")
    let data = try! Data(contentsOf: url!)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try! decoder.decode(HomeFeed.self, from: data)
  }
}

extension Array where Element == FeedItem {
  static var homeMock: [FeedItem] {
    FeedItem.mock.feed.feedItems
  }

  static var scheduleMock: [FeedItem] {
    FeedItem.mock.schedule.feedItems
  }
}

