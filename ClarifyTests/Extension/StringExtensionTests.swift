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
    func testisEmptyOrInt32ReturnsTrueCaseEmpty() {
        let string = ""
        XCTAssertTrue(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32RetrunsTrueCase0() {
        let string = "0"
        XCTAssertTrue(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsTrueCaseInt() {
        let string = "1000"
        XCTAssertTrue(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsFalseCaseText() {
        let string = "text"
        XCTAssertFalse(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsTrueCaseIntStartWith0() {
        let string = "01000"
        XCTAssertTrue(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsTrueCaseIntStartWithMinus() {
        let string = "-1000"
        XCTAssertTrue(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsTrueCaseIntStartWithMinusAnd0() {
        let string = "-01000"
        XCTAssertTrue(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsFalseCaseDouble() {
        let string = "1.000"
        XCTAssertFalse(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsFalseCaseIntWithComma() {
        let string = "1,000"
        XCTAssertFalse(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsTrueCaseUpperLimit() {
        let string = "2147483647"
        XCTAssertTrue(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsFalseCaseOverUpperLimit() {
        let string = "2147483648"
        XCTAssertFalse(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsTrueCaseLowerLimit() {
        let string = "-2147483648"
        XCTAssertTrue(string.isEmptyOrInt32)
    }

    func testisEmptyOrInt32ReturnsFalseCaseUnderLowerLimit() {
        let string = "-2147483649"
        XCTAssertFalse(string.isEmptyOrInt32)
    }
}
