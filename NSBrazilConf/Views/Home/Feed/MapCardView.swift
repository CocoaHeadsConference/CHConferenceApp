
import SwiftUI

struct MapCardView: View {
    
    var viewModel: FeedViewModel

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.placeNameAndAdress)
                    .font(.headline)
            }
            .padding(.leading, 16)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(4)
        .frame(maxWidth: .infinity, minHeight: 286)
        .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 6)
        .padding(.horizontal, 10)
    }
}

struct MapCardView_Previews: PreviewProvider {
    var feed: FeedModel?
    
    static var previews: some View {
        MapCardView(viewModel: FeedViewModel())
    }
}

