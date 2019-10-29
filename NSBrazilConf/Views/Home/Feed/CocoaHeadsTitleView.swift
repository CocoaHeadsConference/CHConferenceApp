//
//  CocoaHeadsTitleView.swift
//  NSBrazilConf
//
//  Created by resource on 01/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct CocoaHeadsTitleView: View {
    init?(feedItem: FeedItem) {
           guard let item = feedItem as? TextFeedItem else { return nil }
           self.feedItem = item
       }

       var feedItem: TextFeedItem
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text(feedItem.text)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 24)
        .padding(.trailing, 24)

    }
}
//
//struct CocoaHeadsTitleView_Previews: PreviewProvider {
//    static var previews: some View {
//        CocoaHeadsTitleView(feedItem: Fee)
//    }
//}
