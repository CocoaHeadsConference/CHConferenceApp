
import SwiftUI

struct HomeList: View {
  let feedViewModel: FeedViewModel

  @Environment(\.horizontalSizeClass) var sizeClass

  var body: some View {
    ScrollView {
      VStack(alignment: .leading ,spacing: 15) {
        ForEach(feedViewModel.homeFeed) { item in
          FeedBuilder.view(for: item)
        }
      }
      .padding(.vertical, 30)
    }
  }
}

#Preview {
  HomeList(feedViewModel: .mock)
}
