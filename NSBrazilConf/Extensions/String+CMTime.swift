//
//  String+CMTime.swift
//  CocoaheadsConf
//
//  Created by Guilherme Rambo on 24/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import Foundation
import CoreMedia

extension String {
    
    init?(time: CMTime) {
        guard time.isValid
            && !time.isIndefinite
            && !time.isNegativeInfinity
            && !time.isPositiveInfinity else { return nil }
       
        self.init(Float(CMTimeGetSeconds(time)))
    }
    
    init?(time: Float) {
        let date = Date(timeInterval: TimeInterval(time), since: Date())
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: date)
        
        var output = ""
        
        if let hours = components.hour, hours > 0 {
            output = output.appendingFormat("%02d:", abs(hours))
        }
        
        if let minutes = components.minute {
            output = output.appendingFormat("%02d:", abs(minutes))
        }
        
        if let seconds = components.second {
            output = output.appendingFormat("%02d", abs(seconds))
        } else {
            return nil
        }
        
        self.init(output)
    }
    
}

extension DateFormatter {
  static let yyyyMMdd: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
