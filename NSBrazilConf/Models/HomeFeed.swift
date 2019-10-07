//
//  HomeFeed.swift
//  NSBrazilConf
//
//  Created by Mauricio Cardozo on 10/6/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

struct HomeFeed: Codable {
    let version: Int
    let feed: FeedDecoder
    let schedule: FeedDecoder
}
