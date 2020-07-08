//
//  StringExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes_Dev

class StringExtensionTests: XCTestCase {
    func testisEmptyOrDecimalReturnsTrueCaseEmpty() {
        let string = ""
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalRetrunsTrueCase0() {
        let string = "0"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseInt() {
        let string = "1000"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsFalseCaseText() {
        let string = "text"
        XCTAssertFalse(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseIntStartWith0() {
        let string = "01000"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseIntStartWithMinus() {
        let string = "-1000"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseIntStartWithMinusAnd0() {
        let string = "-01000"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseDouble() {
        let string = "1.000"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseIntWithComma() {
        let string = "1,000"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseUpperLimitOfInt32() {
        let string = "2147483647"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseOverUpperLimitOfInt32() {
        let string = "2147483648"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseLowerLimitOfInt32() {
        let string = "-2147483648"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }

    func testisEmptyOrDecimalReturnsTrueCaseUnderLowerLimitOfInt32() {
        let string = "-2147483649"
        XCTAssertTrue(string.isEmptyOrDecimal)
    }
}
