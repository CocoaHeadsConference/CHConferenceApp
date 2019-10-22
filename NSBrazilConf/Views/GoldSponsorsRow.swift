//
//  GoldSponsorsRow.swift
//  NSBrazilConf
//
//  Created by resource on 21/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct GoldSponsorsRow: View {
    var goldSponsors = goldSponsorsData

    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gold")
                    .font(.system(size: 26))
                    .fontWeight(.medium)
                    .padding(.leading, 24)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(goldSponsors) { item in
                            GoldSponsorCard(item: item)
                        }
                    }
                    .padding(24)

                }
                .padding(.bottom, 4)
        }
    }
}

struct GoldSponsorsRow_Previews: PreviewProvider {
    static var previews: some View {
        GoldSponsorsRow()
    }
}


let goldSponsorsData = [
    SponsorViewModel(title: "", image: "ic_ifood", color: Color.white, width: 88, height: 72, titleColor: Color.white)
]
