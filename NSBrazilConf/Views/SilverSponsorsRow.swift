//
//  SilverSponsorsRow.swift
//  NSBrazilConf
//
//  Created by resource on 21/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct SilverSponsorsRow: View {
    var silverSponsors = silverSponsorsData

    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Silver")
                    .font(.system(size: 26))
                    .fontWeight(.medium)
                    .padding(.leading, 24)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(silverSponsors) { item in
                            SilverSponsorCard(item: item)
                        }
                    }
                    .padding(24)

                }
                .padding(.bottom, 4)
        }
    }
}

struct SilverSponsorsRow_Previews: PreviewProvider {
    static var previews: some View {
        SilverSponsorsRow()
    }
}


let silverSponsorsData = [
    SponsorViewModel(title: "AirBuddy", image: "ic_airbuddy", color: Color.white, width: 96, height: 88, titleColor: Color.black)
]
