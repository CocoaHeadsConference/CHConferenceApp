//
//  CocoaHeadsBR_WatchApp.swift
//  CocoaHeadsBR Watch Watch App
//
//  Created by Mauricio Cardozo on 01/08/24.
//  Copyright © 2024 Cocoaheadsbr. All rights reserved.
//

import SwiftUI
import NSBrazilLib

@main
struct CocoaHeadsBR_Watch_Watch_AppApp: App {
  var body: some Scene {
    WindowGroup {
    #if DEBUG
      RootView(model: .mock)
    #else
      RootView(model: .init())
    #endif
    }
  }
}
