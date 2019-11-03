

import SwiftUI

struct PlatinumSponsorCard: View {
    var sponsor: Sponsor 
    
    var body: some View {
        VStack(alignment: .center) {
            ImageViewContainer(imageURL: sponsor.image)
        }
        .background(sponsor.background)
        .cornerRadius(10)
        .padding([.leading, .trailing], 5)
    }
}

struct SponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        PlatinumSponsorCard(sponsor: Sponsor(name: "", link: URL(string: "www")!, image: URL(string: "https://nsbrazil.com/images/app/meli-logo.png")!, backgroundColor: "#BABACA")).previewDevice(.iPhone11)
    }
}
