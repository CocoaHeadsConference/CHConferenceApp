//
//  GoldSponsorCard.swift
//  NSBrazilConf
//
//  Created by resource on 21/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct GoldSponsorCard: View {
    
    var item = SponsorViewModel(title: "Banco Itaú", image: "ic_itau", color: Color("Orange"), width: 196, height: 102, titleColor: Color.white)
    
    var body: some View {
        ZStack(alignment: .leading) {
                Image(item.image)
                    .resizable()
                    .frame(width: CGFloat(item.width), height: CGFloat(item.height))
        }
        .frame(width: 48, height: 48)
        .padding(24)
        .background(item.color)
        .cornerRadius(10)
        
    }
}

struct GoldSponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        GoldSponsorCard()
    }
}

