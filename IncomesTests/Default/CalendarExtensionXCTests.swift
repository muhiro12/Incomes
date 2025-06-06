//
//  CalendarExtensionXCTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

@testable import Incomes
import XCTest

final class CalendarExtensionXCTests: XCTestCase {
    func testUtc() {
        let expected = isoDate("2000-01-01T00:00:00Z")

        XCTContext.runActivity(named: "UTC of startOfDay returns startOfDay when target is startOfDay") { _ in
            let result = Calendar.utc.startOfDay(for: isoDate("2000-01-01T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "UTC of startOfDay returns startOfDay when target is same day") { _ in
            let result = Calendar.utc.startOfDay(for: isoDate("2000-01-01T12:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "UTC of startOfDay does not return startOfDay when target is next day") { _ in
            let result = Calendar.utc.startOfDay(for: isoDate("2000-01-02T00:00:00Z"))
            XCTAssertNotEqual(result, expected)
        }
    }

    func testEndOfDay() {
        let expected = isoDate("2000-12-31T23:59:59Z")

        XCTContext.runActivity(named: "endOfDay returns endOfDay when target is endOfDay") { _ in
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T23:59:59Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfDay returns endOfDay when target is same day") { _ in
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfDay does not return endOfDay when target is last day") { _ in
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-11-30T00:00:00Z"))
            XCTAssertNotEqual(result, expected)
        }
    }

    func testStartOfMonth() {
        let expected = isoDate("2000-01-01T00:00:00Z")

        XCTContext.runActivity(named: "startOfMonth returns startOfMonth when target is startOfMonth") { _ in
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-01-01T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfMonth returns startOfMonth when target is same day") { _ in
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-01-01T12:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfMonth returns startOfMonth when target is next day") { _ in
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-01-02T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfMonth does not return startOfMonth when target is next month") { _ in
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-02-01T00:00:00Z"))
            XCTAssertNotEqual(result, expected)
        }
    }

    func testEndOfMonth() {
        let expected = isoDate("2000-12-31T23:59:59Z")

        XCTContext.runActivity(named: "endOfMonth returns endOfMonth when target is endOfMonth") { _ in
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T23:59:59Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfMonth returns endOfMonth when target is same day") { _ in
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfMonth returns endOfMonth when target is last day") { _ in
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-30T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfMonth does not return endOfMonth when target is last month") { _ in
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-11-30T00:00:00Z"))
            XCTAssertNotEqual(result, expected)
        }
    }

    func testStartOfYear() {
        let expected = isoDate("2000-01-01T00:00:00Z")

        XCTContext.runActivity(named: "startOfYear returns startOfYear when target is startOfYear") { _ in
            let result = Calendar.utc.startOfYear(for: isoDate("2000-01-01T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfYear returns startOfYear when target is same day") { _ in
            let result = Calendar.utc.startOfYear(for: isoDate("2000-01-01T12:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfYear returns startOfYear when target is next day") { _ in
            let result = Calendar.utc.startOfYear(for: isoDate("2000-01-02T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfYear returns startOfYear when target is next month") { _ in
            let result = Calendar.utc.startOfYear(for: isoDate("2000-02-01T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfYear does not return startOfYear when target is next year") { _ in
            let result = Calendar.utc.startOfYear(for: isoDate("2001-01-01T00:00:00Z"))
            XCTAssertNotEqual(result, expected)
        }
    }

    func testEndOfYear() {
        let expected = isoDate("2000-12-31T23:59:59Z")

        XCTContext.runActivity(named: "endOfYear returns endOfYear when target is endOfYear") { _ in
            let result = Calendar.utc.endOfYear(for: isoDate("2000-12-31T23:59:59Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfYear returns endOfYear when target is same day") { _ in
            let result = Calendar.utc.endOfYear(for: isoDate("2000-12-31T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfYear returns endOfYear when target is last day") { _ in
            let result = Calendar.utc.endOfYear(for: isoDate("2000-12-30T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfYear returns endOfYear when target is last month") { _ in
            let result = Calendar.utc.endOfYear(for: isoDate("2000-11-30T00:00:00Z"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfYear does not return endOfYear when target is last year") { _ in
            let result = Calendar.utc.endOfYear(for: isoDate("1999-12-31T00:00:00Z"))
            XCTAssertNotEqual(result, expected)
        }
    }
}
