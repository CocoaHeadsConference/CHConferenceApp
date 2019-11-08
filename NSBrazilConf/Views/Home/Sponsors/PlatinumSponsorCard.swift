

import SwiftUI

struct PlatinumSponsorCard: View {
    var sponsor: Sponsor
    @State var showContent = false
    
    var body: some View {
        Button(action: {
            self.showContent.toggle()
        }) {
            VStack(alignment: .center) {
                ImageViewContainer(imageURL: sponsor.image)
            }
            .background(sponsor.background)
            .cornerRadius(10)
            .padding([.leading, .trailing], 5)
        }
        .sheet(isPresented: $showContent, content: {
            SafariView(url: self.sponsor.link)
        })
    }
}

struct SponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        PlatinumSponsorCard(sponsor: Sponsor(name: "", link: URL(string: "www")!, image: URL(string: "https://nsbrazil.com/images/app/meli-logo.png")!, backgroundColor: "#BABACA")).previewDevice(.iPhone11)
    }
}
