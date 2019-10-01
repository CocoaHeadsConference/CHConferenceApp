//
//  EventModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 25/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import Foundation
import CoreLocation

struct EventModel: Codable {

    let name: String
    let headline: String
    let subline: String
    let startDate: Date
    let endDate: Date
    let twitter: String?
    let location: LocationModel
    let codeOfConduct: URL?

}


struct LocationModel: Codable {
    
    let address: String
    let coordinate: CoordinateModel

}

struct CoordinateModel: Codable {
    
    let latitude: Double
    let longitude: Double

}

extension CoordinateModel {
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "long"
    }
}

extension CoordinateModel {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
