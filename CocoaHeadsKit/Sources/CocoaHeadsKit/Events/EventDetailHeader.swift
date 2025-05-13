//
//  EventDetailHeader.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/7/25.
//

import SwiftUI

#warning("FIXME: imageView sizing got fucked again - maybe try just having both images there in a zstack")

struct EventDetailHeader: View {
  let title: String
  let imageURL: URL?
  let imageID: UUID?
  @Binding var scrollPosition: CGPoint
  @State private var imageData: Data?

  @Environment(\.cloudKitService) var cloudKit

  public var body: some View {
    VStack {
      GeometryReader { reader in
        imageView
          .aspectRatio(contentMode: .fill)
          .frame(width: reader.size.width)
          .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
      }
      .frame(maxWidth: .infinity, maxHeight: 250)
      .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
      .padding(3)
      .background {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .foregroundStyle(.background)
      }

      Text(title)
        .font(.title)
        .multilineTextAlignment(.center)
    }
    .padding(.bottom)
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

  @ViewBuilder
  var imageView: some View {
    ZStack {
      if let imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
      } else {
        AsyncImage(url: imageURL, scale: 2)
      }
    }
    .task {
      guard
        imageURL == nil,
        let id = imageID
      else { return }

      do {
        imageData = try await cloudKit.fetchImageAsset(for: id)
      } catch {
        print(error)
      }
    }
  }
}

struct HeaderHeightKey: PreferenceKey {
  static let defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}
