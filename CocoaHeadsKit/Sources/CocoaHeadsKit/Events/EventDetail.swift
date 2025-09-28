//
//  EventDetail.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 4/28/25.
//

import CocoaHeadsCore
import SwiftUI

struct EventDetail: View {
  internal init(title: String, image: URL? = nil, imageID: UUID? = nil, ui: [EventDetailUI], shareURL: URL) {
    self.ui = ui
    self.details = EventDetailUIDetails(title: title, image: image, imageID: imageID, shareURL: shareURL)
  }

  @State private var details: EventDetailUIDetails
  let ui: [EventDetailUI]

  @State private var scrollPosition: CGPoint = .zero
  @State private var headerSize: CGFloat = 0
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack(alignment: .top) {
      EventDetailHeader(
        title: details.title,
        imageURL: details.image,
        imageID: details.imageID,
        scrollPosition: $scrollPosition
      )
      .padding(.vertical)
      .onPreferenceChange(HeaderHeightKey.self) { [$headerSize] height in
        $headerSize.wrappedValue = height
      }

      ScrollView(.vertical) {
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
      .toolbar {
        if !Bundle.main.isAppClip {
          toolbarItems
        }
      }
    }
    .onChange(of: scrollPosition.y) {
      if scrollPosition.y > 180 {
        dismiss()
      }
    }
    .onPreferenceChange(EventDetailsPreferenceKey.self) { [$details] newDetails in
      $details.wrappedValue = newDetails
    }
  }

  @ToolbarContentBuilder
  var toolbarItems: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button {
        dismiss()
      } label: {
        Image(systemName: "chevron.down")
          .padding(4)/// For some reason, a `Button` is smaller than a `ShareLink`
          .toolbarStyle(scrollPosition: scrollPosition.y)
      }
      .buttonStyle(.plain)
    }

    ToolbarItem(placement: .topBarTrailing) {
      ShareLink(item: details.shareURL) {
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
  @ViewBuilder
  fileprivate func toolbarStyle(scrollPosition: CGFloat) -> some View {
    #if os(visionOS)
      self
        .font(.caption)
        .foregroundStyle(.white)
        .padding()
        .background {
          Circle()
            .fill(Color(.lightGray))
            .shadow(radius: scrollPosition < -100 ? 1 : 0)
            .animation(.default, value: scrollPosition)
        }
    #else
      if #available(iOS 26.0, *) {
        self
          .font(.caption)
          .foregroundStyle(Color(.toolbarItem))
      } else {
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
    #endif
  }
}
