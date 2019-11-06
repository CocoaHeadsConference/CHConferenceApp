//
//  Schedule.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 03/11/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

struct Schedule: Codable {
    let feeds: [Feed]
}

struct Feed: Codable {
    let title: String
    let feedItems: [Talk]
}
