//
//  FilteredFeed.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

struct FilteredFeed: Codable {
    let title: String
    let feedItems: FeedDecoder
}

final class FilterFeedItem: FeedItem {
    let feeds: [FilteredFeed]

    private enum CodingKeys: String, CodingKey {
        case feeds
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.feeds = try container.decode([FilteredFeed].self, forKey: .feeds)
        try super.init(from: decoder)
    }
}
