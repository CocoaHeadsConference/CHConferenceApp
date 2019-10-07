import Foundation
import SwiftUI
import MapKit

public struct FeedViewModel {

    @ObservedObject var store = NSBrazilStore()

    public init() { }
    
    public var startDate: String {
        let startDateString = store.confMock.feed[0].startDateText
        return startDateString
    }
    
    public var endDate: String {
        let endDateString = store.confMock.feed[0].endDateText
        return endDateString
    }
    
    public var eventHourFirstDay: String {
        let eventHourFirstDayString = store.confMock.feed[0].startEventHourText
        return eventHourFirstDayString
    }
    
    public var eventHourSecondDay: String {
        let eventHourSecondDayString = store.confMock.feed[0].endEventHourText
        return eventHourSecondDayString
    }
    
    public var coordinate: CLLocationCoordinate2D {
        let confCoordinate = store.confMock.feed[0].location.coordinate 
        let placeCoordinate = CLLocationCoordinate2D(latitude: confCoordinate.latitude, longitude: confCoordinate.longitude)
        return placeCoordinate
    }
    
    public var placeNameAndAdress: String {
        let place = store.confMock.feed[0].place
        let address = store.confMock.feed[0].location.address
        return "\(place) - \(address)"
    }

    var feed: [FeedItem] {
        return store.newData.feed.feedItems
    }
    

}
