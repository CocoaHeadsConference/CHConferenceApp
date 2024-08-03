//
//  MapFeedView.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/7/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI
import MapKit

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
      .frame(maxWidth: .infinity, minHeight: 286)
      #endif
    }

  @ViewBuilder
  var innerView: some View {
    CardView{
      VStack(alignment: .leading) {
        MapView(
          location: feedItem.location,
          annotationTitle: feedItem.title,
          span: feedItem.span)
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
  MapFeedView(feedItem: 
    MapFeedItem(
      location: CLLocationCoordinate2D(),
      span: MKCoordinateSpan(),
      title: "CUBO",
      subtitle: "Itaú")
  )
}
