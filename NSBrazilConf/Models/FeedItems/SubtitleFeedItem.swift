//
//  SubtitleFeedItem.swift
//  NSBrazilConf
//
//  Created by resource on 25/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

final class SubtitleFeedItem: FeedItem {

    let textStyle: String
    let text: String
    let subtext: String

    private enum CodingKeys: String, CodingKey {
        case textStyle, text, subtext
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.textStyle = try container.decode(String.self, forKey: .textStyle)
        self.text = try container.decode(String.self, forKey: .text)
        self.subtext = try container.decode(String.self, forKey: .subtext)
        try super.init(from: decoder)
    }
}
