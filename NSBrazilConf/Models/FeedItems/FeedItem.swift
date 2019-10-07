//
//  FeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

class FeedItem: Codable, Identifiable {
    let id = UUID()
    let type: FeedItemType

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(FeedItemType.self, forKey: .type)
    }
}
