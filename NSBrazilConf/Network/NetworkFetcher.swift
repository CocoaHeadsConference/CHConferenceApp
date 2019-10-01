//
//  NetworkFetcher.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

typealias FetchResult = ()-> Void
typealias JSONDictionary = [String:Any]

enum FetcherDataError: Error {
    case wrongData
    case missingFile
    case missingJSON
}

protocol NetworkFetcher {
    var cache: Cache { get }
    init(cacheService: Cache)
    func fetchJSON(onComplete: @escaping ((JSONDictionary?)-> Void))
    func fetchNewInfo(onComplete: @escaping FetchResult)
    
}

extension NetworkFetcher {
    
    func fetchNewInfo(onComplete: @escaping FetchResult) {
        self.fetchJSON { (json) in
            do {
                guard let json = json else {
                    return
                }
                try self.cache.import(json: json)
                DispatchQueue.main.async {
                    onComplete()
                }
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
    
}
