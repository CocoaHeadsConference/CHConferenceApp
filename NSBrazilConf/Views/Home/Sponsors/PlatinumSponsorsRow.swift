
import SwiftUI

struct PlatinumSponsorsRow: View {
    
    var sponsor: SponsorFeedItem
    
    @State var showContent = false
    
    var body: some View {
        VStack(alignment: .leading) {
                Text("Platinum")
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .padding(.leading, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 38) {
                        ForEach(0..<sponsor.platinumSponsors.count) { index in
                            Button(action: { self.showContent.toggle() }) {
                                GeometryReader { geometry in
                                    PlatinumSponsorCard(
                                        sponsor: self.sponsor.platinumSponsors[index]
                                    )
                                    .sheet(isPresented: self.$showContent) {
                                        SponsorView(
                                            sponsorUrl: self.sponsor.platinumSponsors[index].link,
                                            isPresented: self.showContent
                                        )
                                    }
                                }
                                .frame(width: 124, height: 96)
                                .padding()
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 24)
        }
        
    }
}
