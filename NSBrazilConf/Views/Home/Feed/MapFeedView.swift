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

   var feedItem: MapFeedItem

    var body: some View {
        Button(action: self.openMap) {
            CardView{
                VStack(alignment: HorizontalAlignment.leading) {
                    MapView(location: self.feedItem.location, annotationTitle: self.feedItem.title, span: self.feedItem.span)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(self.feedItem.title) \(self.feedItem.subtitle)")
                            .font(.headline)
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 8)
                }
            }
        }.frame(maxWidth: .infinity, minHeight: 286)
    }
    
    func openMap() {
        let placemark = MKPlacemark(coordinate: self.feedItem.location)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.feedItem.title
        mapItem.openInMaps(launchOptions: nil)
    }
}

struct MapFeedView_Previews: PreviewProvider {
    static var previews: some View {
        MapFeedView(feedItem: MapFeedItem(location: CLLocationCoordinate2D(),
                                          span: MKCoordinateSpan(),
                                          title: "CUBO",
                                          subtitle: "Itaú")
        ).previewDevice(.iPhone11)
    }
}
