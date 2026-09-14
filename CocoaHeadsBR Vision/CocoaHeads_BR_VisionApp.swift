//
//  CocoaHeads_BR_VisionApp.swift
//  CocoaHeads BR Vision
//
//  Created by Mauricio Cardozo on 02/08/24.
//  Copyright © 2024 Cocoaheadsbr. All rights reserved.
//

import CocoaHeadsKit
import SwiftUI

@main
struct CocoaHeads_BR_VisionApp: App {
  @State private var services = CocoaHeadsAppServices()
  var body: some Scene {
    WindowGroup {
      CocoaHeadsAppView(services: services)
    }
    .defaultSize(width: 1100, height: 800)
  }
}
