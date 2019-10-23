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
                HStack {
                    ForEach(goldSponsors) { item in
                        GoldSponsorCard(item: item)
                    }
                }
            }
            .padding(.leading, 24)
        }
        .frame(maxWidth: .some(158), minHeight: 124)//Tive que deixar um hardcode pq eu não consegui alinhar os 4 sponsors no forma de um quandrado 🤷🏻‍♂️
    }
}

struct GoldSponsorsRow_Previews: PreviewProvider {
    static var previews: some View {
        GoldSponsorsRow()
    }
}


let goldSponsorsData = [
    SponsorViewModel(title: "", image: "ic_ifood", color: Color("iFoodColor"), width: 72, height: 48, titleColor: Color.white)
]
