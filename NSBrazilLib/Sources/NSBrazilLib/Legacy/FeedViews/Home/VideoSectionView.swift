//
//  PastVideosViewSection.swift
//  NSBrazilConf
//
//  Created by Douglas Alexandre Barros Taquary on 23/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct VideoSectionView: View {

  init?(feedItem: FeedItem) {
    guard let item = feedItem as? VideoFeedItem else { return nil }
    self.feedItem = item
  }

  var feedItem: VideoFeedItem

  @State var showContent = false
  @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 24) {
        ForEach(feedItem.videos) { item in
          if self.horizontalSizeClass == .compact {
            GeometryReader { geometry in
              VideoCardView(video: item)
                .rotation3DEffect(
                  Angle(degrees: Double((geometry.frame(in: .global).minX - 40) / -30)),
                  axis: (x: 0, y: 10, z: 0))
            }.frame(width: 250)
          } else {
            VideoCardView(video: item)
          }
        }
      }
      .padding(24)
    }
    .frame(height: 416)
  }
}

struct VideoSectionView_Previews: PreviewProvider {
  static var previews: some View {
    let store = NSBrazilStore()
    let item = store.data!.feed.feedItems.filter { $0 is VideoFeedItem }.first!

    return Group {
      VideoSectionView(feedItem: item)
    }
  }
}
