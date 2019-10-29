//
//  PastVideosViewSection.swift
//  NSBrazilConf
//
//  Created by Douglas Alexandre Barros Taquary on 23/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct PastVideosViewSection: View {
    init?(feedItem: FeedItem) {
           guard let item = feedItem as? VideoFeedItem else { return nil }
           self.feedItem = item
       }

       var feedItem: VideoFeedItem
    
    
    @State var showContent = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(0..<feedItem.videos.count) { index in
                    Button(action: { self.showContent.toggle() }) {
                        GeometryReader { geometry in
                            PastEditionCardView(
                                video: self.feedItem.videos[index]
                            )
                            .rotation3DEffect(Angle(degrees: Double((geometry.frame(in: .global).minX - 40) / -30)), axis: (x: 0, y: 10, z: 0))
                            .sheet(isPresented: self.$showContent) { VideoView() }
                        }
                        .frame(width: 246, height: 360)
                    }
                }
            }
            .padding(24)
        }
        .frame(height: 416)
        .padding()
    }
}


