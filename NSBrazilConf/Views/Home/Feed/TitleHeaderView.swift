
import SwiftUI

struct TitleHeaderView: View {
    init?(feedItem: FeedItem) {
           guard let item = feedItem as? SubtitleFeedItem else { return nil }
           self.feedItem = item
       }

       var feedItem: SubtitleFeedItem
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text(feedItem.text)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                Text(feedItem.subtext)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 24)

    }

}
