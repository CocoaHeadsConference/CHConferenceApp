//
//  FeedView.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 28/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct FeedView: View {
    
    let feed: Feed
    
    var body: some View {
        List(feed.feedItems) { talk in
            NavigationLink(destination: TalkDetailView(talk: talk)) {
                TalkView(talk: talk)
                    .lineLimit(2)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
        }
        .listStyle(CarouselListStyle())
        .navigationBarTitle(feed.title)
        .contextMenu {
            Button(action: {
                FeedManager.shared.fetchSchedule()
            }) {
                VStack(alignment: .center) {
                    Image(systemName: "goforward").font(.title)
                    Text("Refresh")
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(feed: NSBrazilData.mock.schedule[0].feeds[0])
    }
}
#endif
