//
//  VideoFeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

final class VideoFeedItem: FeedItem {
    let title: String
    let subtitle: String
    let videos: [Video]

    private enum CodingKeys: String, CodingKey {
        case title, subtitle, videos
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.videos = try container.decode([Video].self, forKey: .videos)
        try super.init(from: decoder)
    }
}
