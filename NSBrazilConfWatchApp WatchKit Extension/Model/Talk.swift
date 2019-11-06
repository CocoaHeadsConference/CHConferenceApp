//
//  Talk.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 03/11/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

struct Talk: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let speaker: String
    let name: String
    let image: String?
    
    var dateDescription: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
    var timeDescription: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: date)
    }
    
}
