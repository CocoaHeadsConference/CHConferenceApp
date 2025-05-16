//
//  Card.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 4/28/25.
//

import SwiftUI

struct Card<Content: View>: View {
  var title: String? = nil
  var contentInset: (Edge.Set, CGFloat?) = (.all, 20)
  @ViewBuilder let content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 26) {
      if let title {
        Text(title)
          .font(.title2)
          .fontWeight(.light)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      content()
    }
    .padding(contentInset.0, contentInset.1)
    .frame(maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color(.systemBackground))
        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 4)
    }
  }
}

#Preview {
  VStack {
    Card {
      Text("Olá CocoaHeads")
    }

    Card(title: "CocoaHeads, olá!") {
      Text("Olá CocoaHeads")
    }
  }
  .padding()
  .frame(maxHeight: .infinity)
  .background {
    Rectangle()
      .fill(.secondary)
      .ignoresSafeArea()
  }
}
