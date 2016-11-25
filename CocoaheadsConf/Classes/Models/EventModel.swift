//
//  EventModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 25/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import Foundation
import Marshal

struct EventModel: Unmarshaling {

    let name: String
    let startDate: Date
    let endDate: Date
    
    init(object: MarshaledObject) throws {
        name = try object.value(for: "name")
        startDate = try object.value(for: "startDate")
        endDate = try object.value(for: "endDate")
    }
    
}
