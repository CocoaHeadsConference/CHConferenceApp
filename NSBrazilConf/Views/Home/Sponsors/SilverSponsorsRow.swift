//
//  SilverSponsorsRow.swift
//  NSBrazilConf
//
//  Created by resource on 21/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct SilverSponsorsRow: View {
    var sponsor: SponsorFeedItem
    
    @State var showContent = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Silver")
                .font(.system(size: 18))
                .fontWeight(.medium)
                .padding(.leading, 24)
                
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<sponsor.silverSponsors.count) { index in
                        Button(action: { self.showContent.toggle() }) {
                            GeometryReader { geometry in
                                SilverSponsorCard(
                                    sponsor: self.sponsor.silverSponsors[index]
                                )
                                .sheet(isPresented: self.$showContent) {
                                    SponsorView(
                                        sponsorUrl: self.self.sponsor.silverSponsors[index].link,
                                        isPresented: self.showContent
                                    )
                                }
                            }
                            .frame(width: 96, height: 96)
                        }
                    }
                }
            }
            .padding(.leading, 24)
        }
    }
}
