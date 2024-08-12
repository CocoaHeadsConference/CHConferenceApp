//
//  RoomModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct RoomModel: Codable, Identifiable {

    let id: Int
    let title: String
    let capacity: Int

}
