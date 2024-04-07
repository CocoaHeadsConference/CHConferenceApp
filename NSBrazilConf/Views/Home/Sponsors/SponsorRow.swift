
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
                   PlatinumSponsorCard(sponsor: $0)
                }
            }.padding(.horizontal, 5)
        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
    }
}

struct PlatinumSponsorsRow_Previews: PreviewProvider {
    static var previews: some View {
        let sponsors = [
            Sponsor(name: "Mercado Livre",
                    link: URL(string: "https://mercadolivre.com")!,
                    image: URL(string: "https://nsbrazil.com/images/app/meli-logo.png")!,
                    backgroundColor: "#BABACA"),
            Sponsor(name: "Mercado Livre",
                    link: URL(string: "https://mercadolivre.com")!,
                    image: URL(string: "https://nsbrazil.com/images/app/meli-logo.png")!,
                    backgroundColor: "#BABACA")
        ]

        return Group {
            SponsorRow(title: "Platinum", sponsors: sponsors).previewDevice(.iPhone11)
            SponsorRow(title: "Platinum", sponsors: sponsors).previewDevice(.iPhoneSE)
        }
    }
}
