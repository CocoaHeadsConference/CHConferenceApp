//
//  FilterFeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/31/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation
import SwiftUI

struct FilterFeedView: View {

    init?(feedItem: FeedItem) {
       guard let item = feedItem as? FilterFeedItem else { return nil }
       self.feedItem = item
    }

    var feedItem: FilterFeedItem

    @State var selectedFeed: Int = 0

    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        if horizontalSizeClass == .regular {
            return AnyView(
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<feedItem.feeds.count) { index in
                            ScrollView (.vertical) {
                                VStack {
                                    Text(self.feedItem.feeds[index].title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .padding(2)
                                    .padding([.leading, .trailing], 8)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                                    ForEach(self.feedItem.feeds[index].decoder.feedItems) { item in
                                        FeedBuilder.view(for: item)
                                    }
                                }
                            }
                            if (index != self.feedItem.feeds.count - 1) {
                                Divider()
                            }
                        }
                    }.frame(width: 1400)
                        .padding([.leading, .trailing], 20)
                }
            )
        } else {
            return AnyView(
                VStack {
                Picker("", selection: $selectedFeed) {
                    ForEach(0..<self.feedItem.feeds.count) { index in
                        Text(self.feedItem.feeds[index].title).tag(index)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                    .padding([.leading, .trailing], 10)

                Text(self.feedItem.feeds[self.selectedFeed].title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(2)
                .padding([.leading, .trailing], 8)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                List(self.feedItem.feeds[selectedFeed].decoder.feedItems) { item in
                    FeedBuilder.view(for: item)
                }
            }
        )
        }
    }
}

struct FilterFeedView_Previews: PreviewProvider {

    static var items: [FeedItem] = [
        TalkFeedItem(date: Date(), name: "Jonas", speaker: "Jonas", image: ""),
        TalkFeedItem(date: Date(), name: "Jonas", speaker: "Jonas", image: ""),
        TalkFeedItem(date: Date(), name: "Jonas", speaker: "Jonas", image: "")
    ]

    static var previews: some View {
        let item = FilterFeedItem(feeds: [
            FilteredFeed(title: "Sexta", decoder: FeedDecoder(feedItems: items)),
            FilteredFeed(title: "Sabado", decoder: FeedDecoder(feedItems: items)),
            FilteredFeed(title: "Domingo", decoder: FeedDecoder(feedItems: items))
        ])

        return Group {
            FilterFeedView(feedItem: item).previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            FilterFeedView(feedItem: item).previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }
}
