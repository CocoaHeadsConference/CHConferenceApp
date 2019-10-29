//
//  MapFeedView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/7/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct MapFeedView: View, FeedViewProtocol {
    init?(feedItem: FeedItem) {
           guard let item = feedItem as? MapFeedItem else { return nil }
           self.feedItem = item
       }

       var feedItem: MapFeedItem

    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            MapView(location: feedItem.location, annotationTitle: feedItem.title, span: feedItem.span)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(feedItem.title) \(feedItem.subtitle)")
                    .font(.headline)
            }
            .padding(.leading, 16)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(4)
        .frame(maxWidth: .infinity, minHeight: 286)
        .shadow(color: Color.gray.opacity(0.4), radius: 8, x: 0, y: 6)
        .padding(.leading, 24)
        .padding(.trailing, 24)
    }
}
