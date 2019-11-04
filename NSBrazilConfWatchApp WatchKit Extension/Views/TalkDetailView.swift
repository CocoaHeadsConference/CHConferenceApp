//
//  TalkDetailView.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 03/11/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct TalkDetailView: View {
    
    let talk: Talk
    
    var body: some View {
        ScrollView {
            TalkView(talk: talk)
        }.navigationBarTitle("Talk")
    }
}

#if DEBUG
struct TalkDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TalkDetailView(talk: NSBrazilData.mock.schedule[0].feeds[0].feedItems[0])
    }
}
#endif
