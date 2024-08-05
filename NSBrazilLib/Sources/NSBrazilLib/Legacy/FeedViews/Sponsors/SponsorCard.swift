import SwiftUI

struct SponsorCard: View {
    var sponsor: Sponsor

    var body: some View {
      WatchFriendlyLink(url: sponsor.link) {
        VStack(alignment: .center) {
            ImageViewContainer(imageURL: sponsor.image)
        }
        .background(sponsor.background)
        .cornerRadius(10)
        .padding([.leading, .trailing], 5)
      }
    }
}

#Preview {
  SponsorCard(
    sponsor: Sponsor(
      name: "",
      link: URL(string: "mercadolivre.com.br")!,
      image: URL(string: "https://nsbrazil.com/images/app/meli-logo.png")!,
      backgroundColor: "#BABACA"))
}
