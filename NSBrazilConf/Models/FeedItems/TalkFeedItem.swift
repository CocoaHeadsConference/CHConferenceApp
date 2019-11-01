//
//  TalkFeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

class TalkFeedItem: FeedItem {
    let date: Date
    let name: String
    let speaker: String
    let image: String

    private enum CodingKeys: String, CodingKey {
        case date, name, speaker, image
    }

    #if DEBUG
    init(date: Date, name: String, speaker: String, image: String) {
        self.date = date
        self.name = name
        self.speaker = speaker
        self.image = image
        super.init(type: .talk)
    }
    #endif

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(Date.self, forKey: .date)
        self.name = try container.decode(String.self, forKey: .name)
        self.speaker = try container.decode(String.self, forKey: .speaker)
        self.image = try container.decode(String.self, forKey: .image)
        try super.init(from: decoder)
    }
}
