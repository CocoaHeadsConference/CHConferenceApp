//
//  SilverSponsorCard.swift
//  NSBrazilConf
//
//  Created by resource on 21/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct SilverSponsorCard: View {
    
    var item = SponsorViewModel(title: "Banco Itaú", image: "ic_airbuddy", color: Color("Orange"), width: 96, height: 96, titleColor: Color.white)
    
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
                .frame(width: 48, height: 48)
                .padding(24)
                .background(Color.black)
                .cornerRadius(10)
        
    }
}

struct SilverSponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        SilverSponsorCard()
    }
}


