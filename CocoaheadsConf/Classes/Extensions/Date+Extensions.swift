//
//  Date+Extensions.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 09/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

extension Date {

    static var sharedCalendar = Calendar.autoupdatingCurrent
    static var now: Date { return Date() }
    static var dateComponents: Set<Calendar.Component> = [.year, .month, .day]
    static var commonComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
    var components: DateComponents { return Date.sharedCalendar.dateComponents(Date.commonComponents, from: self) }
    
    var startOfDay: Date {
        let midnight = DateComponents(year: components.year, month: components.month, day: components.day)
        return Date.sharedCalendar.date(from: midnight) ?? self
    }
    
    var startOfHour: Date {
        let startOfHour = DateComponents(year: components.year, month: components.month, day: components.day, hour: components.hour)
        return Date.sharedCalendar.date(from: startOfHour) ?? self
    }
    
    static func remote(dateString: String)-> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        return formatter.date(from: dateString)
    }
    
}
