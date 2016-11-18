//
//  URLSessionFetcher.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

final class URLSessionFetcher: NetworkFetcher {
    
    
    init(cacheService: Cache) {
        
    }


    required init() {
        
    }
    
    func fetchNewInfo(onComplete: FetchResult) {
        onComplete()
    }
    
}
