//
//  DisplayTalkTests.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 09/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import XCTest
@testable import CocoaheadsConf

class DisplayTalkTests: XCTestCase {
    
    var sampleCache: Cache!
    
    override func setUp() {
        super.setUp()
        sampleCache = Cache()
        let fakeFetcher = LocalDataFetcher(cacheService: sampleCache)
        fakeFetcher.fetchNewInfo(onComplete: {})
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGroupTalks() {
        XCTAssert(sampleCache.talks.count > 0)
        let groupedTalks = groupByDate(talks: sampleCache.talks)
        XCTAssert(groupedTalks.keys.count == 3)
    }
    
}
