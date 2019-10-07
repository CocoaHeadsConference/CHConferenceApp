//
//  TextFeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

final class TextFeedItem: FeedItem {
    let textStyle: String
    let text: String

    private enum CodingKeys: String, CodingKey {
        case textStyle, text
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.textStyle = try container.decode(String.self, forKey: .textStyle)
        self.text = try container.decode(String.self, forKey: .text)
        try super.init(from: decoder)
    }
}
