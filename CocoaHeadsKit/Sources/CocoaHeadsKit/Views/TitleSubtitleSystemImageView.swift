//
//  TitleSubtitleSystemImageView.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 4/28/25.
//

import SwiftUI

struct TitleSubtitleSystemImageView: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey
  let systemName: String

  var body: some View {
    TitleView(title: title, systemName: systemName) {
      Text(subtitle)
        .foregroundStyle(.secondary)
        .font(.callout)
    }
  }
}

struct TitleView<Content: View>: View {
  let title: LocalizedStringKey
  let systemName: String
  let content: () -> Content

  var body: some View {
    HStack(alignment: .titleSubtitleAlignment, spacing: 8) {
      Image(systemName: systemName)
        .foregroundStyle(.tertiary)
        .alignmentGuide(.titleSubtitleAlignment) { d in
          d[VerticalAlignment.center]
        }

      VStack(alignment: .leading) {
        Text(title)
          .font(.title3)
          .alignmentGuide(.titleSubtitleAlignment) { d in
            d[VerticalAlignment.center]
          }

        content()
      }
      .fontWeight(.light)
      .kerning(-0.5)

      Spacer()
    }
  }
}

extension VerticalAlignment {
  struct TitleSubtitleAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context[.leading]
    }
  }

  static let titleSubtitleAlignment = VerticalAlignment(TitleSubtitleAlignment.self)
}
