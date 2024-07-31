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
        VStack(alignment: .center, spacing: 10) {
            if !feedItem.platinumSponsors.isEmpty {
                SponsorRow(title: "Platinum", sponsors: feedItem.platinumSponsors).frame(height: 250)
            }
            if !feedItem.goldSponsors.isEmpty {
                SponsorRow(title: "Gold", sponsors: feedItem.goldSponsors).frame(height: 200)
            }
            if !feedItem.silverSponsors.isEmpty {
                SponsorRow(title: "Silver", sponsors: feedItem.silverSponsors).frame(height: 150)
            }
        }
    }
}

#Preview {
  let sponsor = Sponsor(name: "Mercado Livre",
                        link: URL(string: "https://mercadolivre.com")!,
                        image: URL(string: "https://nsbrazil.com/images/app/meli-logo.png")!,
                        backgroundColor: "#BABACA")
  let platinum = [sponsor, sponsor]
  let gold = [sponsor]

  let item = SponsorFeedItem(platinum: platinum, gold: gold, silver: gold)

  return SponsorsViewSection(feedItem: item)
}
