//
//  OptionalExtensionTests.swift
//  ClarifyTests
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Clarify

class OptionalExtensionTests: XCTestCase {
    func testStringCaseNil() {
        let optional: Any? = nil
        XCTAssertEqual(optional.string, "")
    }

    func testStringCaseEmptyString() {
        let optional: String? = ""
        XCTAssertEqual(optional.string, "")
    }
}
