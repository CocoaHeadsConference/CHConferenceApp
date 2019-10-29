//
//  SilverSponsorCard.swift
//  NSBrazilConf
//
//  Created by resource on 21/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct SilverSponsorCard: View {
    var sponsor: Sponsor
    
    var body: some View {
        ZStack(alignment: .center) {
            ImageViewContainer(
                imageURL: sponsor.image,
                width: 72,
                height: 48
            )
        }
        .frame(width: 48, height: 48)
        .padding(24)
        .background(sponsor.background)
        .cornerRadius(10)
        
    }
}

struct SilverSponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        SilverSponsorCard(sponsor: Sponsor(name: "", link: URL(string: "https://upload.wikimedia.org")!, image: URL(string: "https://upload.wikimedia.org/wikipedia/pt/0/04/Logotipo_MercadoLivre.png")!, backgroundColor: "#FEE801"))
    }
}


