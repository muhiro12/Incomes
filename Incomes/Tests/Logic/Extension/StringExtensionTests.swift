//
//  StringExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

@testable import IncomesPlaygrounds
import XCTest

// swiftlint:disable all
class StringExtensionTests: XCTestCase {
    func testIsNotEmpty() {
        XCTContext.runActivity(named: "Text returns true") { _ in
            let string = "text"
            XCTAssertTrue(string.isNotEmpty)
        }

        XCTContext.runActivity(named: "Empty returns false") { _ in
            let string = ""
            XCTAssertFalse(string.isNotEmpty)
        }
    }

    func testIsEmptyOrDecimal() {
        XCTContext.runActivity(named: "Empty returns true") { _ in
            let string = ""
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "0 returns true") { _ in
            let string = "0"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Int returns true") { _ in
            let string = "1000"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Text returns false") { _ in
            let string = "text"
            XCTAssertFalse(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Int starting with 0 returns true") { _ in
            let string = "01000"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Int starting with minus returns true") { _ in
            let string = "-1000"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Int starting with minus and 0 returns true") { _ in
            let string = "-01000"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Double returns true") { _ in
            let string = "1.000"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Int with comma returns true") { _ in
            let string = "1,000"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Int32 upper limit returns true") { _ in
            let string = "2147483647"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Numbers overing Int32 upper limit returns true") { _ in
            let string = "2147483648"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Int32 lower limit returns true") { _ in
            let string = "-2147483648"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }

        XCTContext.runActivity(named: "Numbers overing Int lower limit returns true") { _ in
            let string = "-2147483649"
            XCTAssertTrue(string.isEmptyOrDecimal)
        }
    }

    func testDecimalValue() {
        XCTContext.runActivity(named: "Text returns 0") { _ in
            let string = "text"
            XCTAssertEqual(string.decimalValue, 0)
        }

        XCTContext.runActivity(named: "0 returns 0") { _ in
            let string = "0"
            XCTAssertEqual(string.decimalValue, 0)
        }

        XCTContext.runActivity(named: "Int returns decimal") { _ in
            let string = "1000"
            XCTAssertEqual(string.decimalValue, 1_000)
        }
    }
}
// swiftlint:enable all
