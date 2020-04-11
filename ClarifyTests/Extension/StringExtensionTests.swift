//
//  StringExtensionTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class StringExtensionTests: XCTestCase {
    func testIsValidAsInt32ReturnsTrueCaseEmpty() {
        let string = ""
        XCTAssertTrue(string.isValidAsInt32)
    }

    func testIsValidAsInt32RetrunsTrueCase0() {
        let string = "0"
        XCTAssertTrue(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsTrueCaseInt() {
        let string = "1000"
        XCTAssertTrue(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsFalseCaseText() {
        let string = "text"
        XCTAssertFalse(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsTrueCaseIntStartWith0() {
        let string = "01000"
        XCTAssertTrue(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsTrueCaseIntStartWithMinus() {
        let string = "-1000"
        XCTAssertTrue(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsTrueCaseIntStartWithMinusAnd0() {
        let string = "-01000"
        XCTAssertTrue(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsFalseCaseDouble() {
        let string = "1.000"
        XCTAssertFalse(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsFalseCaseIntWithComma() {
        let string = "1,000"
        XCTAssertFalse(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsTrueCaseUpperLimit() {
        let string = "2147483647"
        XCTAssertTrue(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsFalseCaseOverUpperLimit() {
        let string = "2147483648"
        XCTAssertFalse(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsTrueCaseLowerLimit() {
        let string = "-2147483648"
        XCTAssertTrue(string.isValidAsInt32)
    }

    func testIsValidAsInt32ReturnsFalseCaseUnderLowerLimit() {
        let string = "-2147483649"
        XCTAssertFalse(string.isValidAsInt32)
    }
}
