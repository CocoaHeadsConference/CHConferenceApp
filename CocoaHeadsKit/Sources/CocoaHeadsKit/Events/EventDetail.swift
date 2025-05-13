//
//  EventDetail.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 4/28/25.
//

import SwiftUI

struct EventDetail: View {
  let title: String
  let image: URL?
  let imageID: UUID?
  let ui: [EventDetailUI]
  let shareURL: URL

  @State private var scrollPosition: CGPoint = .zero
  @State private var headerSize: CGFloat = 0
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack(alignment: .top) {
      EventDetailHeader(
        title: title,
        imageURL: image,
        imageID: imageID,
        scrollPosition: $scrollPosition
      )
      .padding(.vertical)
      .onPreferenceChange(HeaderHeightKey.self) { [$headerSize] height in
        $headerSize.wrappedValue = height
      }

      ScrollView {
        PositionObservingView(
          coordinateSpace: .named("EventDetail"),
          position: $scrollPosition
        ) {
          Color.clear
            .frame(height: headerSize)
        }

        VStack(alignment: .leading, spacing: 16) {
          EventDetailRenderer(ui: ui)
        }
        .padding()
      }
      .coordinateSpace(name: "EventDetail")
      .background {
        Rectangle().fill(.quinary)
          .ignoresSafeArea()
      }
      .toolbarBackground(.hidden, for: .navigationBar)
      .toolbar { toolbarItems }
    }
    .onChange(of: scrollPosition.y) {
      if scrollPosition.y > 180 {
        dismiss()
      }
    }
  }

  #warning("FIXME: Fix the fact that these buttons are not the same size")
  @ToolbarContentBuilder
  var toolbarItems: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button {
        dismiss()
      } label: {
        Image(systemName: "chevron.down")
          .toolbarStyle(scrollPosition: scrollPosition.y)
      }
      .buttonStyle(.plain)
    }

    ToolbarItem(placement: .topBarTrailing) {
      ShareLink(item: shareURL) {
        Image(systemName: "square.and.arrow.up")
          .offset(y: -2)
          .toolbarStyle(scrollPosition: scrollPosition.y)
      }
      .buttonStyle(.plain)
    }
  }
}

#Preview("Full") {
  NavigationStack {
    EventDetail(
      title: "CocoaHeads @ Apple Developer Academy",
      image: nil,
      imageID: nil,
      ui: Event.mock.ui,
      shareURL: Event.mock.rsvpURL
    )
  }
}

extension View {
  fileprivate func toolbarStyle(scrollPosition: CGFloat) -> some View {
    self
      .font(.caption)
      .foregroundStyle(Color.buttonBottomGradient)
      .padding()
      .background {
        Circle()
          .fill(.background)
          .shadow(radius: scrollPosition < -100 ? 1 : 0)
          .animation(.default, value: scrollPosition)
      }
  }
}
