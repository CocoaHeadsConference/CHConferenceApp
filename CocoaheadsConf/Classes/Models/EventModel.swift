//
//  EventModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 25/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import Foundation
import CoreLocation
import Marshal

struct EventModel: Unmarshaling {

    let name: String
    let headline: String
    let subline: String
    let startDate: Date
    let endDate: Date
    let twitterHandle: String?
    let location: LocationModel
    let codeOfConductURL: URL?
    
    init(object: MarshaledObject) throws {
        name = try object.value(for: "name")
        headline = try object.value(for: "headline")
        subline = try object.value(for: "subline")
        startDate = try object.value(for: "startDate")
        endDate = try object.value(for: "endDate")
        location = try object.value(for: "location")
        twitterHandle = try? object.value(for: "twitter")
        codeOfConductURL = try? object.value(for: "codeOfConduct")
    }
    
}


struct LocationModel: Unmarshaling {
    
    let address: String
    let coordinate: CoordinateModel
    
    init(object: MarshaledObject) throws {
        address = try object.value(for: "address")
        coordinate = try object.value(for: "coordinate")
    }
    
}

struct CoordinateModel: Unmarshaling {
    
    let latitude: Double
    let longitude: Double
    
    init(object: MarshaledObject) throws {
        latitude = try object.value(for: "lat")
        longitude = try object.value(for: "long")
    }
    
}

extension CoordinateModel {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
