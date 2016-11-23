//
//  SponsorModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 22/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Marshal

struct SponsorModel: Unmarshaling {

    let id: Int
    let title: String
    let image: URL
    let url: URL
    
    init(object: MarshaledObject) throws {
        self.id = try object.value(for: "id")
        self.title = try object.value(for: "title")
        self.url = try object.value(for: "url")
        self.image = try object.value(for: "image")
    }
    
}
