//
//  SilverSponsorCard.swift
//  NSBrazilConf
//
//  Created by resource on 21/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct SilverSponsorCard: View {
    
    var item = SponsorViewModel(title: "Banco Itaú", image: "ic_itau", color: Color("Orange"), width: 196, height: 102, titleColor: Color.white)
    
    var body: some View {
        ZStack(alignment: .center) {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(item.titleColor)
                        .padding()

                    Image(item.image)
                        .resizable()
                        .frame(width: CGFloat(item.width), height: CGFloat(item.height))
                }
                .frame(width: 64, height: 64)
                .padding(24)
                .background(item.color)
                .cornerRadius(10)
                .shadow(radius: 10)
        
    }
}

struct SilverSponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        SilverSponsorCard()
    }
}


