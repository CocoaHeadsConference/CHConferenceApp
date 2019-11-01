
import SwiftUI

struct SponsorRow: View {

    var title: String
    var sponsors: [Sponsor]
    
    @State var showContent = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.system(size: 24))
                .fontWeight(.medium)
            HStack {
                ForEach(0..<sponsors.count) { index in
                    Button(action: { self.showContent.toggle() }) {
                        PlatinumSponsorCard(sponsor: self.sponsors[index])
                            .sheet(isPresented: self.$showContent) {
                                SafariView(url: self.sponsors[index].link)
                        }
                    }
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
