
import SwiftUI

struct SponsorsRow: View {
    var sponsors = sponsorsData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("NSBrazil é apoiada por")
                    .font(.system(size: 26))
                    .fontWeight(.heavy)
                    .padding(.leading, 40)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(sponsors) { item in
                            SponsorCard(item: item)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 32)
                    .padding(.leading, 24)
                }
            }
        
    }
}

struct CertificateRow_Previews: PreviewProvider {
    static var previews: some View {
        SponsorsRow()
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
    SponsorViewModel(title: "", image: "ic_itau", color: Color("Orange"), width: 220, height: 120, titleColor: Color.white),
    SponsorViewModel(title: "AirBuddy", image: "ic_airbuddy", color: Color.white, width: 120, height: 120, titleColor: Color.black),
    SponsorViewModel(title: "", image: "ic_banco_inter", color: Color.white, width: 340, height: 236, titleColor: Color.white)
]
