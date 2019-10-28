

import SwiftUI

struct PlatinumSponsorCard: View {
    var sponsor: Sponsor 
    
    var body: some View {
        VStack(alignment: .center) {
            ImageViewContainer(
                imageURL: sponsor.image,
                width: 124,
                height: 72
            )

        }
        .background(sponsor.background)
        .cornerRadius(10)
        .frame(width: 124, height: 72)
        .padding(24)
        
    }
}

struct SponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        PlatinumSponsorCard(sponsor: Sponsor(name: "", link: URL(string: "www")!, image: URL(string: "www")!, backgroundColor: ""))
    }
}


