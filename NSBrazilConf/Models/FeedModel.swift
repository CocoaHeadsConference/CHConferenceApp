
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
    
    private let formatter: ISO8601DateFormatter = {
       let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone]
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM \n EEEE"
        return formatter
    }()

    var startDateText: String {
        let date = startDateTextFunc()
        return date
    }

    var endDateText: String {
        let date = endDateTextFunc()
        return date
    }

    var startEventHourText: String {
        let date = startHourText()
        return date
    }
    
    var endEventHourText: String {
        let date = endHourText()
        return date
    }

    func startDateTextFunc() -> String {
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter.string(from: startDate)
    }

    private func endDateTextFunc() -> String {
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter.string(from: endDate)
    }

    private func startHourText() -> String {
        dateFormatter.dateFormat = "EEEE - HH:mm"
        return dateFormatter.string(from: startDate)
    }
    
    private func endHourText() -> String {
        dateFormatter.dateFormat = "EEEE - HH:mm"
        return dateFormatter.string(from: endDate)
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

extension FeedModel {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int.self, forKey: .id)
    type = try container.decode(String.self, forKey: .type)
    place = try container.decode(String.self, forKey: .place)
    
    let startDateString = try container.decode(String.self, forKey: .startDate)
    if let date = formatter.date(from: startDateString) {
        startDate = date
    } else {
        throw DecodingError.dataCorruptedError(forKey: .startDate,
              in: container,
              debugDescription: "Date string does not match format expected by formatter.")
    }
    
    let endDateString = try container.decode(String.self, forKey: .endDate)
    if let date = formatter.date(from: endDateString) {
        endDate = date
    } else {
        throw DecodingError.dataCorruptedError(forKey: .endDate,
              in: container,
              debugDescription: "Date string does not match format expected by formatter.")
    }
    twitter = try container.decode(String.self, forKey: .twitter)
    location = try container.decode(LocationModel.self, forKey: .location)
    codeOfConduct = try container.decode(URL.self, forKey: .codeOfConduct)

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
