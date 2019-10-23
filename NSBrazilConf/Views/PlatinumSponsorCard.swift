

import SwiftUI

struct PlatinumSponsorCard: View {
    var item = SponsorViewModel(title: "Banco Itaú", image: "ic_itau", color: Color.white, width: 220, height: 120, titleColor: Color.white)
    
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
        
    }
}

struct SponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        PlatinumSponsorCard()
    }
}
