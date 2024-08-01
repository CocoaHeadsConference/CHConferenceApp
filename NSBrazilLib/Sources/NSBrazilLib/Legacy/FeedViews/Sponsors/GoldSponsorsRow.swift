
import SwiftUI

struct GoldSponsorsRow: View {
    var sponsor: SponsorFeedItem
    
    @State var showContent = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gold")
                .font(.system(size: 18))
                .fontWeight(.medium)
                .padding(.leading, 24)
                
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<sponsor.goldSponsors.count) { index in
                        Button(action: { self.showContent.toggle() }) {
                            GeometryReader { geometry in
                                GoldSponsorCard(
                                    sponsor: self.sponsor.goldSponsors[index]
                                )
                                .sheet(isPresented: self.$showContent) {
                                    SponsorView(
                                        sponsorUrl: self.sponsor.goldSponsors[index].link,
                                        isPresented: self.showContent
                                    )
                                }
                            }
                            .frame(width: 96, height: 96)
                        }                        
                    }
                }
            }
            .padding(.leading, 24)
        }
    }
}

