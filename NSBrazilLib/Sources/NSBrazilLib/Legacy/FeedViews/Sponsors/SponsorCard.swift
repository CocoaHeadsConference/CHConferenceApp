import SwiftUI

struct SponsorCard: View {
  var sponsor: Sponsor

  var body: some View {
    WatchFriendlyLink(url: sponsor.link) {
      VStack(alignment: .center) {
        AsyncImage(
          url: sponsor.image,
          scale: 1
        ) { image in
          image
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .padding(10)
        } placeholder: {
          ProgressView()
        }
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
