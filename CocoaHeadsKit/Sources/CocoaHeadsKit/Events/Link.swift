//
//  LinkView.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/7/25.
//

import SwiftUI

struct LinkView: View {
  let url: URL
  let title: String?

  var body: some View {
    Link(destination: url) {
      HStack(spacing: 4) {
        Image(systemName: "link")
          .font(.caption2)
          .foregroundStyle(.white)
          .padding(3)
          .background {
            Circle()
              .fill(.blue)
          }
        Text(actualTitle)
          .fontWeight(.light)
          .kerning(0)
      }
      .padding(8)
      .background {
        RoundedRectangle(cornerRadius: 50, style: .continuous)
          .fill(.quinary)
      }
    }
    .buttonStyle(.plain)
  }

  private var actualTitle: String {
    let unwrappedTitle = title ?? ""
    guard !unwrappedTitle.isEmpty else { return url.host() ?? "" }
    return title ?? url.host() ?? ""
  }
}

#Preview {
  LinkView(url: .apple, title: nil)
  LinkView(url: .apple, title: "Apple ponto com")
}
