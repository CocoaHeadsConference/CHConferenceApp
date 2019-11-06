//
//  NSBrazilData.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 28/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import Foundation

struct NSBrazilData: Codable {
    var schedule: [Schedule]
    
    static var mock: NSBrazilData {
        let url = Bundle.main.url(forResource: "2019", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(NSBrazilData.self, from: data)
    }
    
}
