//
//  MapFeedView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/7/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import MapKit
import SwiftUI

struct MapFeedView: View, FeedViewProtocol {
  init?(feedItem: FeedItem) {
    guard let item = feedItem as? MapFeedItem else { return nil }
    self.feedItem = item
  }

  let feedItem: MapFeedItem

  var body: some View {
    #if os(visionOS)
      innerView
        .onTapGesture {
          openMap()
        }
        .frame(maxWidth: .infinity, minHeight: 286)
    #else
      Button(action: openMap) {
        innerView
      }
      .buttonStyle(.plain)
      .frame(maxWidth: .infinity, minHeight: 286)
    #endif
  }

  @ViewBuilder
  var innerView: some View {
    CardView {
      VStack(alignment: .leading) {
        Map(
          initialPosition: .camera(
            .init(
              centerCoordinate: feedItem.location,
              distance: 1000.0))
        )
        .disabled(true)
        VStack(alignment: .leading, spacing: 4) {
          Text("\(feedItem.title) \(feedItem.subtitle)")
            .font(.headline)
        }
        .padding(.leading, 16)
        .padding(.bottom, 8)
      }
    }
  }

  func openMap() {
    let placemark = MKPlacemark(coordinate: feedItem.location)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = self.feedItem.title
    mapItem.openInMaps(launchOptions: nil)
  }
}

#Preview {
  MapFeedView(
    feedItem:
      MapFeedItem(
        location: CLLocationCoordinate2D(
          latitude: -23.5965911,
          longitude: -46.6867937),
        span: MKCoordinateSpan(),
        title: "CUBO",
        subtitle: "Itaú")
  )
}
