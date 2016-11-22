//
//  LocalDataFetcher.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

final class LocalDataFetcher: NetworkFetcher {

    enum FakeDataError: Error {
        case wrongData
        case missingFile
    }
    
    let fakeURL: URL?
    let cache: Cache

    init(cacheService: Cache) {
        cache = cacheService
        fakeURL = Bundle.main.url(forResource: "LocalData", withExtension: "json")
    }
    
    func fetchNewInfo(onComplete: () -> Void) {
        do {
            guard let url = fakeURL else {
                throw FakeDataError.missingFile
            }
            let jsonData = try Data(contentsOf: url)
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? [String:Any] else {
                throw FakeDataError.wrongData
            }
            try cache.import(json: json)
            onComplete()
        }
        catch {
            print("Error getting json: \(error)")
        }
        
    }
    
}
