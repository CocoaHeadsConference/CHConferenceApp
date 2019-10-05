//
//  NSBrazilData.swift
//  NSBrazilConf
//
//  Created by resource on 01/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation


struct NSBrazilData: Codable {
    let feed: [FeedModel]
    let sponsors: [SponsorModel]
    let schedule: [ScheduleModel]
    let videos: [VideoModel]
    
}



extension NSBrazilData {
    enum CodingKeys: String, CodingKey {
        case feed
        case sponsors
        case schedule
        case videos
    }
}

