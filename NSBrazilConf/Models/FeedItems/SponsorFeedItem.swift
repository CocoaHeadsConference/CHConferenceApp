//
//  SponsorFeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

final class SponsorFeedItem: FeedItem {
    let platinumSponsors: [Sponsor]
    let goldSponsors: [Sponsor]
    let silverSponsors: [Sponsor]

    private enum CodingKeys: String, CodingKey {
        case platinum, gold, silver
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.platinumSponsors = try container.decode([Sponsor].self, forKey: .platinum)
        self.goldSponsors = try container.decode([Sponsor].self, forKey: .gold)
        self.silverSponsors = try container.decode([Sponsor].self, forKey: .silver)
        try super.init(from: decoder)
    }
}
