//
//  CardView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 11/1/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import MapKit
import SwiftUI

struct CardView<Content>: View where Content: View {

  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    Group {
      content()
    }
    .background(.quinary)
    .cornerRadius(8)
    .padding()
    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
  }
}

#Preview {
  CardView {
    Text("Test text")
      .padding()
  }
}
