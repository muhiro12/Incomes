//
//  IntExtensionTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class IntExtensionTests: XCTestCase {
    func testAsCurrencyReturnsNotEmptyStringCase0() {
        let int = 0
        XCTAssertFalse(int.asCurrency.isEmpty)
    }

    func testAsCurrencyReturnsNotEmptyStringCasePlus() {
        let int = 1000
        XCTAssertFalse(int.asCurrency.isEmpty)
    }

    func testAsCurrencyReturnsNotEmptyStringCaseMinus() {
        let int = -1000
        XCTAssertFalse(int.asCurrency.isEmpty)
    }

    func testAsMinusCurrencyReturnsNotEmptyStringCase0() {
        let int = 0
        XCTAssertFalse(int.asMinusCurrency.isEmpty)
    }

    func testAsMinusCurrencyReturnsNotEmptyStringCasePlus() {
        let int = 1000
        XCTAssertFalse(int.asMinusCurrency.isEmpty)
    }

    func testAsMinusCurrencyReturnsNotEmptyStringCaseMinus() {
        let int = -1000
        XCTAssertFalse(int.asMinusCurrency.isEmpty)
    }
}
