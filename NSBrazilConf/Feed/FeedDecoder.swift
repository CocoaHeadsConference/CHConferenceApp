//
//  FeedDecoder.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

struct FeedDecoder: Codable {
    let feedItems: [FeedItem]

    private enum FeedItemKey: CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        var items: [FeedItem] = []
        var unkeyedFeedItems = try decoder.unkeyedContainer()
        var itemArray = unkeyedFeedItems

        while !unkeyedFeedItems.isAtEnd {
            let item = try unkeyedFeedItems.nestedContainer(keyedBy: FeedItemKey.self)
            let type = (try? item.decode(FeedItemType.self, forKey: FeedItemKey.type)) ?? .unknown

            do {
                if let builtType = FeedBuilder.typeDictionary[type] {
                    items.append(try itemArray.decode(builtType))
                }
            } catch(let error) {
                print(error)
                _ = try itemArray.decode(UnknownItem<FeedItem>.self)
            }
        }

        self.feedItems = items
    }
}
