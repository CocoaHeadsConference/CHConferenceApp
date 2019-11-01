//
//  CocoaHeadsTitleView.swift
//  NSBrazilConf
//
//  Created by resource on 01/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct TitleView: View {
    init?(feedItem: FeedItem) {
        guard let item = feedItem as? TextFeedItem else { return nil }
        self.text = item.text
    }

    init(text: String) {
        self.text = text
    }

    var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text(text)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }
}

struct CocoaHeadsTitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(text: "O evento nacional do CocoaHeads Brasil")
    }
}
