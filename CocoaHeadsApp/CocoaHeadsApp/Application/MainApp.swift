//
//  MainApp.swift
//  CocoaHeadsApp
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import App
import ComposableArchitecture
import SwiftUI

#warning("Please rename to your app name")
@main
struct MainApp: App {
  var body: some Scene {
    let store = Store(
      initialState: AppFeature.State(),
      reducer: { AppFeature() }
    )

    WindowGroup {
      AppView(store: store)
    }
  }
}
