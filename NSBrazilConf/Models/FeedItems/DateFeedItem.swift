//
//  DateFeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

final class DateFeedItem: FeedItem {
    let dates: [String]

    private enum CodingKeys: String, CodingKey {
        case dates
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dates = try container.decode([String].self, forKey: .dates)
        try super.init(from: decoder)
    }
}
