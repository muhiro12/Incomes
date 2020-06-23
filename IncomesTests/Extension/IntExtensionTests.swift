//
//  IntExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class IntExtensionTests: XCTestCase {
    func testAsCurrencyReturnsNotEmptyStringCase0() {
        let int = 0
        XCTAssertNotNil(int.asCurrency)
    }

    func testAsCurrencyReturnsNotEmptyStringCasePlus() {
        let int = 1000
        XCTAssertNotNil(int.asCurrency)
    }

    func testAsCurrencyReturnsNotEmptyStringCaseMinus() {
        let int = -1000
        XCTAssertNotNil(int.asCurrency)
    }

    func testAsMinusCurrencyReturnsNotEmptyStringCase0() {
        let int = 0
        XCTAssertNotNil(int.asMinusCurrency)
    }

    func testAsMinusCurrencyReturnsNotEmptyStringCasePlus() {
        let int = 1000
        XCTAssertNotNil(int.asMinusCurrency)
    }

    func testAsMinusCurrencyReturnsNotEmptyStringCaseMinus() {
        let int = -1000
        XCTAssertNotNil(int.asMinusCurrency)
    }
}
