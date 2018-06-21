//
//  jarvis_iosTests.swift
//  jarvis-iosTests
//
//  Created by Seong ho Hong on 2018. 5. 9..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import XCTest
@testable import jarvis_ios

class LoginWithNaverIdTests: XCTestCase {
    let clovaConeection = LoginWithNaverId()
    
    override func setUp() {
        super.setUp()
        clovaConeection.delegate = self
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
//    func testSetClovaAccessToken() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        XCTAssertNotEqual(clovaConeection.CICToken, "no token yet")
//    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
