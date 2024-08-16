//
//  ContentView.swift
//  CocoaHeads BR Vision
//
//  Created by Mauricio Cardozo on 02/08/24.
//  Copyright © 2024 Cocoaheadsbr. All rights reserved.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Model3D(named: "Scene", bundle: realityKitContentBundle)
        .padding(.bottom, 50)

      Text("Hello, world!")
    }
    .padding()
  }
}

#Preview(windowStyle: .automatic) {
  ContentView()
}
