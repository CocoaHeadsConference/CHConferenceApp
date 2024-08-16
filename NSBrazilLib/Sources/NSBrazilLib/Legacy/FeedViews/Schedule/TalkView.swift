//
//  TalkView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/31/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation
import SwiftUI

struct TalkView: View {

  init?(feedItem: FeedItem) {
    guard let item = feedItem as? TalkFeedItem else { return nil }
    self.feedItem = item
  }

  var feedItem: TalkFeedItem

  var body: some View {
    HStack(spacing: 12.0) {
      image
      VStack(alignment: .leading, spacing: 5) {
        Spacer().frame(maxHeight: 5)
        Text(feedItem.name)
          .font(.headline)

        Text(feedItem.speaker)
          .lineLimit(3)
          .font(.system(size: 14))
          .lineSpacing(4)

        Text(date())
          .font(.callout)
          .fontWeight(.bold)
          .foregroundColor(.gray)
        Spacer().frame(maxHeight: 5)
      }
    }
    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    .padding(2)
  }

  @ViewBuilder
  private var image: some View {
    AsyncImage(
      url: URL(string: feedItem.image),
      scale: 1
    ) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 80, height: 80)
        .background(Color(.buttonBackground))
        .cornerRadius(40)
    } placeholder: {
      ProgressView()
    }
  }

  func date() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: feedItem.date).uppercased()
  }
}

#Preview {
  TalkView(
    feedItem: TalkFeedItem(
      date: Date(),
      name: "Colocando Swift na sua UI",
      speaker: "Agostinho Carrara",
      image: "https://nsbrazil.com/images/app/meli-logo.png"
    )
  )
}
