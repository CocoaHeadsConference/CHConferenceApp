
import SwiftUI

struct MapCardView: View {
    
    @ObservedObject var infos = NSBrazilStore()

    var body: some View {
        VStack(alignment: .leading) {
            MapView(location: infos.confMock.feed[0].location)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(infos.confMock.feed[0].place) - \(infos.confMock.feed[0].location.address)")
                    .font(.headline)
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
    var feed: FeedModel?
    
    static var previews: some View {
        MapCardView()
    }
}
