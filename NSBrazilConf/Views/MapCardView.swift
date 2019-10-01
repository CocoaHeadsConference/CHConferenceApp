
import SwiftUI

struct MapCardView: View {
    var body: some View {
        VStack(alignment: .leading) {
            MapView()
            VStack(alignment: .leading, spacing: 4) {
                Text("CUBO Itaú - Alameda Vicente Pinzon,54")
                    .font(.headline)
                Text("Vila Olímpia - SP")
                    .font(.subheadline)
            }
            .padding(.leading, 16)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(4)
        .frame(maxWidth: .infinity, minHeight: 286)
        .shadow(radius: 10)
        .padding(.leading, 24)
        .padding(.trailing, 24)
    }
}

struct MapCardView_Previews: PreviewProvider {
    static var previews: some View {
        MapCardView()
    }
}
