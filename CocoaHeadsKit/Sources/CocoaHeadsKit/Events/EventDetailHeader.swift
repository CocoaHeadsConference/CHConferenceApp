//
//  EventDetailHeader.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/7/25.
//

import SwiftUI

// TODO: Nicer image placeholder and image loading transition

struct EventDetailHeader: View {
  let title: String
  let imageURL: URL?
  let imageID: UUID?
  @Binding var scrollPosition: CGPoint
  @State private var height: CGFloat = 0

  public var body: some View {
    VStack {
      InnerImage(imageURL: imageURL, imageID: imageID)
      Text(title)
        .font(.title)
        .multilineTextAlignment(.center)
    }
    .id(title)
    .background(
      GeometryReader { proxy in
        Color.clear
          .preference(key: HeaderHeightKey.self, value: proxy.size.height)
      }
    )
    .blur(radius: min(-(scrollPosition.y / 35), 15))
    .rotationEffect(
      .degrees(
        -max(
          min(Double(-scrollPosition.y) / 50, 2),
          0
        )
      )
    )
    .offset(y: max(scrollPosition.y / 2, -100))
    .frame(alignment: .top)
    .padding(.horizontal)
  }
}

struct HeaderHeightKey: PreferenceKey {
  static let defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    let nextValue = nextValue()
    if nextValue.rounded() < value.rounded() { return }
    value = nextValue.rounded()
  }
}

private struct InnerImage: View {
  let imageURL: URL?
  let imageID: UUID?
  @Environment(\.cloudKitService) private var cloudKit
  @State private var image: Image?

  var body: some View {
    ZStack {
      if let image {
        image
          .resizable()
      } else {
        AsyncImage(url: imageURL, scale: 2)
      }
    }
    .aspectRatio(contentMode: .fill)
    .padding(.horizontal)
    .containerRelativeFrame(.horizontal) { size, axis in
      size * 0.9
    }
    .frame(maxHeight: 250)
    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    .padding(3)
    .background {
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .foregroundStyle(.background)
    }
    .task {
      guard
        imageURL == nil,
        let id = imageID
      else { return }

      do {
        guard
          let data = try await cloudKit.fetchImageAsset(for: id),
          let uiImage = UIImage(data: data)
        else {
          return
        }

        image = Image(uiImage: uiImage)
      } catch {
        print(error)
      }
    }
  }
}
