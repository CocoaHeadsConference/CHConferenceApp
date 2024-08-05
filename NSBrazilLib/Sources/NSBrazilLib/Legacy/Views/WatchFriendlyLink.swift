//
//  WatchFriendlyLink.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/31/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import AuthenticationServices
import Foundation
import SwiftUI

struct WatchFriendlyLink<Content: View>: View {
  let url: URL
  @ViewBuilder var label: () -> Content

  var body: some View {
    Button(action: {
      let session = ASWebAuthenticationSession(
          url: url,
          callbackURLScheme: nil
      ) { _, _ in }
      session.prefersEphemeralWebBrowserSession = true
      session.start()
    }, label: {
      label()
    })
    .buttonStyle(.plain)
  }
}

#Preview {
  WatchFriendlyLink(url: URL(string: "https://apple.com")!) {
    Text("Tap to Apple")
  }
}
