//
//  Date+Marshal.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Marshal

extension Date : ValueType {
    public static func value(from object: Any) throws -> Date {
        guard let dateString = object as? String else {
            throw MarshalError.typeMismatch(expected: String.self, actual: type(of: object))
        }
        guard let date = Date.remote(dateString: dateString) else {
            throw MarshalError.typeMismatch(expected: "yyyy-MM-dd'T'HH:mm:ssZZZZZ date string", actual: dateString)
        }
        return date
    }
}
