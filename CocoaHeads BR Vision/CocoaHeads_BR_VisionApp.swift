//
//  CocoaHeads_BR_VisionApp.swift
//  CocoaHeads BR Vision
//
//  Created by Mauricio Cardozo on 02/08/24.
//  Copyright © 2024 Cocoaheadsbr. All rights reserved.
//

import NSBrazilLib
import SwiftUI

@main
struct CocoaHeads_BR_VisionApp: App {
    var body: some Scene {
        WindowGroup {
#if DEBUG
  HomeTabBar(model: .mock)
#else
  HomeTabBar(model: FeedViewModel())
#endif
        }
    }
}
