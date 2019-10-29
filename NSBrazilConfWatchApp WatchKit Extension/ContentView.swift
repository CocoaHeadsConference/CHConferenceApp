//
//  ContentView.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 28/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    let talks: [TalkModel]
    
    var body: some View {
        List(talks) { talk in
            NavigationLink(destination: TalkDetailsView(talk: talk)) {
                TalkItemView(talk: talk)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
        }
        .listStyle(CarouselListStyle())
        .navigationBarTitle("Talks")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(talks: NSBrazilData.mock.schedule[0].talks)
    }
}
