
import SwiftUI

struct SponsorRow: View {

    var title: String
    var sponsors: [Sponsor]
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.system(size: 24))
                .fontWeight(.medium)
            HStack {
                ForEach(sponsors) {
                   SponsorCard(sponsor: $0)
                }
            }.padding(.horizontal, 5)
        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
  SponsorRow(
    title: "Platinum",
    sponsors: [
      Sponsor(name: "Mercado Livre",
              link: URL(string: "https://mercadolivre.com")!,
              image: URL(string: "https://nsbrazil.com/images/app/meli-logo.png")!,
              backgroundColor: "#BABACA"),
      Sponsor(name: "Mercado Livre",
              link: URL(string: "https://mercadolivre.com")!,
              image: URL(string: "https://nsbrazil.com/images/app/meli-logo.png")!,
              backgroundColor: "#BABACA")
  ])
}
