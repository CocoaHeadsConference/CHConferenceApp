//
//  ParseDataTest.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 08/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import XCTest
@testable import CocoaheadsConf

class ParseDataTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testParseDate() {
        let remoteDateString = "2016-11-09T12:04:41-0300"
        let date = Date.remote(dateString: remoteDateString)
        XCTAssert(date != nil)
    }
    
    func testParse() {
        let sampleCache = Cache()
        let fakeFetcher = LocalDataFetcher(cacheService: sampleCache)
        let parseExpectation = expectation(description: "parse should be done")
        fakeFetcher.fetchNewInfo {
            parseExpectation.fulfill()
            XCTAssert(sampleCache.rooms.count == 3)
            XCTAssert(sampleCache.speakers.count == 3)
            XCTAssert(sampleCache.talks.count == 4)
        }
        waitForExpectations(timeout: 1.0) { error in
            XCTAssert(error == nil)
        }
    }
    
    func testParsePerformance() {
        let sampleCache = Cache()
        let fakeFetcher = LocalDataFetcher(cacheService: sampleCache)
        self.measure {
            fakeFetcher.fetchNewInfo(onComplete: {})
        }
    }
    
}
