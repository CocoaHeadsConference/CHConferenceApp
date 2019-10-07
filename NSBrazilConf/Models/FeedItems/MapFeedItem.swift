//
//  MapFeedItem.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation
import MapKit

final class MapFeedItem: FeedItem {

    private struct Span: Codable {
        let latDelta: Double
        let lngDelta: Double
    }

    let location: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    let title: String
    let subtitle: String

    private enum CodingKeys: String, CodingKey {
        case lat, lng, span, title, subtitle
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try container.decode(Double.self, forKey: .lat)
        let lng = try container.decode(Double.self, forKey: .lng)
        let latLocation = CLLocationDegrees(exactly: lat) ?? CLLocationDegrees()
        let lngLocation = CLLocationDegrees(exactly: lng) ?? CLLocationDegrees()
        self.location = CLLocationCoordinate2D(latitude: latLocation, longitude: lngLocation)
        let span = try container.decode(Span.self, forKey: .span)
        let latSpan = CLLocationDegrees(exactly: span.latDelta) ?? CLLocationDegrees()
        let lngSpan = CLLocationDegrees(exactly: span.lngDelta) ?? CLLocationDegrees()
        self.span = MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: lngSpan)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        try super.init(from: decoder)
    }
}
