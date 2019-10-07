//
//  TalkFeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

class TalkFeedItem: FeedItem {
    let date: String
    let name: String
    let speaker: String
    let image: URL

    private enum CodingKeys: String, CodingKey {
        case date, name, speaker, image
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(String.self, forKey: .date)
        self.name = try container.decode(String.self, forKey: .name)
        self.speaker = try container.decode(String.self, forKey: .speaker)
        self.image = try container.decode(URL.self, forKey: .image)
        try super.init(from: decoder)
    }
}
