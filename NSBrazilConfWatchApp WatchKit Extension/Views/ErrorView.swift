//
//  ErrorView.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 03/11/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    
    let error: Error
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 8) {
                Text(error.localizedDescription)
                Button(action: FeedManager.shared.fetchSchedule) {
                    Text("Try again")
                }
            }
        }
    }
}

#if DEBUG
struct FakeError: LocalizedError {
    
    var errorDescription: String? {
        return "Sample error"
    }
    
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: FakeError())
    }
}
#endif
