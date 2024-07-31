

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
        .buttonBorderShape(.roundedRectangle)
        .sheet(isPresented: $showContent, content: {
          VideoView(videoUrl: sponsor.link)
          #if os(visionOS)
            .frame(minWidth: 500, minHeight: 500)
          #endif
        })
    }
}

#Preview {
  PlatinumSponsorCard(
    sponsor: Sponsor(
      name: "",
      link: URL(string: "mercadolivre.com.br")!,
      image: URL(string: "https://nsbrazil.com/images/app/meli-logo.png")!,
      backgroundColor: "#BABACA"))
}
