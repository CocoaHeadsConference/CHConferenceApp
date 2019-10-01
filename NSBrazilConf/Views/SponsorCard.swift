

import SwiftUI

struct SponsorCard: View {
    var item = Sponsor(title: "Banco Itaú", image: "ic_itau", color: Color("Orange"), width: 220, height: 120, titleColor: Color.white)
    
    var body: some View {
        return VStack {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(item.titleColor)
                        .padding(.leading, 20)
                    Image(item.image)
                        .resizable()
                        .frame(width: CGFloat(item.width), height: CGFloat(item.height))
                }
                .frame(width: 340, height: 220)
                .background(item.color) 
                .cornerRadius(10)
                .shadow(radius: 10)
        
    }
}

struct SponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        SponsorCard()
    }
}
