//
//  TalkItemView.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 28/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct TalkItemView: View {
    
    let talk: TalkModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(talk.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(talk.speaker)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                Text(talk.dateDescription)
                    .font(.footnote)
                Text(talk.type.title.uppercased())
                    .font(.footnote)
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
    
    
}

struct TalkItemView_Previews: PreviewProvider {
    static var previews: some View {
        TalkItemView(talk: NSBrazilData.mock.schedule[0].talks[0])
    }
}
