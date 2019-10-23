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
                HStack(spacing: 12) {
                    ForEach(silverSponsors) { item in
                        SilverSponsorCard(item: item)
                    }
                }
            }
            .padding(.leading, 24)
        }
    }
}

struct SilverSponsorsRow_Previews: PreviewProvider {
    static var previews: some View {
        SilverSponsorsRow()
    }
}


let silverSponsorsData = [
    SponsorViewModel(title: "AirBuddy", image: "ic_airbuddy", color: Color.white, width: 80, height: 80, titleColor: Color.black)
]
