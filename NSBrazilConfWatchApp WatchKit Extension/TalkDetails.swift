//
//  TalkDetails.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 28/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct TalkDetailsView: View {
    
    let talk: TalkModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                TalkItemView(talk: talk)
                Text(talk.description ?? "No description available")
                    .lineLimit(nil)
            }.fixedSize(horizontal: false, vertical: true)
        }
        .navigationBarTitle("Details")
    }
    
}

struct TalkDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TalkDetailsView(talk: NSBrazilData.mock.schedule[0].talks[0])
    }
}
