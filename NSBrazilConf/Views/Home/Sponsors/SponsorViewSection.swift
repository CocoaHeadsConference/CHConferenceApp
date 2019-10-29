//
//  SponsorViewSection.swift
//  NSBrazilConf
//
//  Created by Douglas Alexandre Barros Taquary on 23/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct SponsorsViewSection: View, FeedViewProtocol {
    
    init?(feedItem: FeedItem) {
           guard let item = feedItem as? SponsorFeedItem else { return nil }
           self.feedItem = item
       }

       var feedItem: SponsorFeedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            PlatinumSponsorsRow(sponsor: feedItem)
            HStack {
                GoldSponsorsRow(sponsor: feedItem)
                SilverSponsorsRow(sponsor: feedItem)
                Spacer()
            }
        }
    }
}
