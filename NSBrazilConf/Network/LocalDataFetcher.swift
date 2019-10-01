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
    
    func fetchJSON(onComplete: @escaping ((JSONDictionary?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = self.fakeURL else {
                return onComplete(nil)
            }
            guard let jsonData = try? Data(contentsOf: url),
                let json = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? JSONDictionary else {
                return onComplete(nil)
            }
            onComplete(json)
        }
    }
    
}
