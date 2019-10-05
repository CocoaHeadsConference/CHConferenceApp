//
//  EventModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 25/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import Foundation
import CoreLocation

struct FeedModel: Codable, Identifiable {

    let id: Int
    let type: String
    let place: String
    let startDate: Date
    let endDate: Date
    let twitter: String
    let location: LocationModel
    let codeOfConduct: URL?
    
    private let formatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM \n EEEE"
        return formatter
    }()
    
//    var startDateText: Date? {
//        didSet {
//            self.startDateText = convertDateToString(from: startDate)
//        }
//    }
//
//    var endDateText: String? {
//        didSet {
//
//            self.endDateText = convertDateToString(from: endDate)
//        }
//    }
//
//    var hourText: String? {
//        didSet {
//            self.hourText = hourText(from: startDate)
//        }
//    }

    private func convertDateToString(from date: Date)-> String {
        formatter.dateFormat = "dd MMM"
        return String("\(formatter.string(from: date))")
    }
    
    private func hourText(from date: Date)-> String {
        formatter.dateFormat = "\nHH:mm"
        return String("\(formatter.string(from: date))")
    }

}

extension FeedModel {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case place = "place"
        case startDate = "startDate"
        case endDate = "endDate"
        case twitter = "twitter"
        case location = "location"
        case codeOfConduct = "codeOfConduct"
    }
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
