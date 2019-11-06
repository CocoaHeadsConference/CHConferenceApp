//
//  TalkView.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 28/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct TalkView: View {
    
    let talk: Talk
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(talk.name)
                    .font(.headline)
                Text(talk.speaker)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                Text(talk.timeDescription ?? "No time provided")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
    
    
}

#if DEBUG
struct TalkItemView_Previews: PreviewProvider {
    static var previews: some View {
        TalkView(talk: NSBrazilData.mock.schedule[0].feeds[0].feedItems[0])
    }
}
#endif
