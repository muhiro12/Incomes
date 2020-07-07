//
//  DateExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes_Dev

class DateExtensionTests: XCTestCase {
    func testYearReturnsYyyyCase19700101() {
        let date = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(date.year, "1970")
    }
}
