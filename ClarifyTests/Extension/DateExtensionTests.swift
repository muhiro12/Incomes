//
//  DateExtensionTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class DateExtensionTests: XCTestCase {
    func testYyyyMMReturnsYyyyMMCase19700101() {
        let date = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(date.yyyyMM, "1970/01")
    }

    func testMMddReturnsMMddCase10700101() {
        let date = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(date.MMdd, "01/01")
    }
}
