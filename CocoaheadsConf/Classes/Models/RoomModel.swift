//
//  RoomModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Marshal

struct RoomModel: Unmarshaling {

    let id: Int
    let title: String
    let capacity: Int
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        title = try object.value(for: "title")
        capacity = try object.value(for: "capacity")
    }
    
}
