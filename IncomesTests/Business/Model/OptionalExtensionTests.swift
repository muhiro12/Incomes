//
//  OptionalExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class OptionalExtensionTests: XCTestCase {
    func testStringCaseNil() {
        let optional: Any? = nil
        XCTAssertEqual(optional.string, "")
    }

    func testStringCaseEmptyString() {
        let optional: String? = ""
        XCTAssertEqual(optional.string, "")
    }

    func testStringCaseString() {
        let optional: String? = "test"
        XCTAssertEqual(optional.string, "test")
    }

    func testStringCaseInt0() {
        let optional: Int? = 0
        XCTAssertEqual(optional.string, "0")
    }

    func testStringCaseInt10() {
        let optional: Int? = 10
        XCTAssertEqual(optional.string, "10")
    }

    func testStringCaseEmptyArray() {
        let optional: [Any]? = []
        XCTAssertEqual(optional.string, "[]")
    }

    func testStringCaseStringArray() {
        let optional: [Any]? = ["test"]
        XCTAssertEqual(optional.string, "[\"test\"]")
    }

    func testStringCaseIntArray() {
        let optional: [Any]? = [0]
        XCTAssertEqual(optional.string, "[0]")
    }

    func testStringCaseEmptyDictionary() {
        let optional: [String: Any]? = [:]
        XCTAssertEqual(optional.string, "[:]")
    }

    func testStringCaseStringDictionary() {
        let optional: [String: Any]? = ["test": "test"]
        XCTAssertEqual(optional.string, "[\"test\": \"test\"]")
    }

    func testStringCaseIntDictionary() {
        let optional: [String: Any]? = ["test": 0]
        XCTAssertEqual(optional.string, "[\"test\": 0]")
    }
}
