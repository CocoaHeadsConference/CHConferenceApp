
import SwiftUI

struct PlatinumSponsorsRow: View {
    var sponsors = sponsorsData
    
    var body: some View {
        VStack(alignment: .leading) {
                Text("Platinum")
                    .font(.system(size: 26))
                    .fontWeight(.medium)
                    .padding(.leading, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 48) {
                        ForEach(sponsors) { item in
                            PlatinumSponsorCard(item: item)
                        }
                    }
                    .padding(.leading, 24)
                }
        }
        
    }
}

struct PlatinumSponsorsRow_Previews: PreviewProvider {
    static var previews: some View {
        PlatinumSponsorsRow()
    }
}

struct SponsorViewModel: Identifiable {
    var id = UUID()
    var title: String
    var image: String
    var color: Color
    var width: Int
    var height: Int
    var titleColor: Color
}


let sponsorsData = [
    SponsorViewModel(title: "", image: "ic_mercado_livre", color: Color.white, width: 164, height: 124, titleColor: Color.clear),
    SponsorViewModel(title: "", image: "ic_banco_inter", color: Color.white, width: 196, height: 124, titleColor: Color.white)
]