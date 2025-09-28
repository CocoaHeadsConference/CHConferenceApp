//
//  TicketCard.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/3/25.
//

import SwiftUI

struct TicketCard<Content: View>: View {
  @ViewBuilder var content: () -> Content

  var body: some View {
    VStack(alignment: .leading) {
      content()
    }
    .background(alignment: .top) {
      Circle()
        .fill(.quaternary)
        .frame(width: 90)
        .offset(y: -60)
    }
    .clipped()
    .platformBackground()
  }
}

extension View {
  @ViewBuilder
  fileprivate func platformBackground() -> some View {
    #if os(visionOS)
      self
        .background {
          RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color(.lightGray))
            .stroke(.black.opacity(0.1))
            .shadow(color: .black.opacity(0.1), radius: 7, x: 0, y: 3)
            .shadow(color: .black.opacity(0.09), radius: 13, x: 0, y: 13)
            .shadow(color: .black.opacity(0.05), radius: 18, x: 0, y: 30)
            .shadow(color: .black.opacity(0.01), radius: 21, x: 0, y: 54)
        }
    #else
      self
        .background {
          RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color(.systemBackground))
            .stroke(.black.opacity(0.1))
            .shadow(color: .black.opacity(0.1), radius: 7, x: 0, y: 3)
            .shadow(color: .black.opacity(0.09), radius: 13, x: 0, y: 13)
            .shadow(color: .black.opacity(0.05), radius: 18, x: 0, y: 30)
            .shadow(color: .black.opacity(0.01), radius: 21, x: 0, y: 54)
        }
    #endif
  }
}
