//
//  NetworkFetcher.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

typealias FetchResult = ()-> Void

protocol NetworkFetcher {
    init(cacheService: Cache)
    func fetchNewInfo(onComplete: FetchResult)
    
}
