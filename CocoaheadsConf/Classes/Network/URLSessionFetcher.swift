//
//  URLSessionFetcher.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

final class URLSessionFetcher: NetworkFetcher {
    
    enum DataError: Error {
        case wrongData
    }
    
    let cache: Cache
    let session: URLSession
    let jsonURL: URL
    
    init(cacheService: Cache) {
        cache = cacheService
        jsonURL = URL(string: "http://cocoaheadsconference.com.br/app/data.json")!
        session = URLSession.shared
    }
    
    func fetchJSON(onComplete: @escaping ((JSONDictionary?) -> Void)) {
        session.dataTask(with: jsonURL) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error)")
                return onComplete(nil)
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? JSONDictionary else {
                return onComplete(nil)
            }
            onComplete(json)
        }
    }
    
}
