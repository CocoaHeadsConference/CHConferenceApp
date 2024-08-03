
import SwiftUI

struct GoldSponsorCard: View {
    var sponsor: Sponsor

    var body: some View {
        ZStack(alignment: .leading) {
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

struct GoldSponsorCard_Previews: PreviewProvider {
    static var previews: some View {
        GoldSponsorCard(sponsor: Sponsor(name: "", link: URL(string: "www")!, image: URL(string: "www")!, backgroundColor: ""))
    }
}

