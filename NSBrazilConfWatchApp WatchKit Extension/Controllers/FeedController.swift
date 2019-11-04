//
//  FeedController.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 28/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import WatchKit
import SwiftUI

class FeedController: WKHostingController<FeedView> {
    
    var feed: Feed?
    
    override func awake(withContext context: Any?) {
        guard let feed = context as? Feed else { return }
        self.feed = feed
    }
    
    override var body: FeedView {
        return FeedView(feed: feed!)
    }
}
