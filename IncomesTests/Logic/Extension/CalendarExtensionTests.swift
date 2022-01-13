//
//  CalendarExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class CalendarExtensionTests: XCTestCase {
    let date: (String) -> Date = { string in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .init(secondsFromGMT: 0)
        return formatter.date(from: string)!
    }

    func testUtc() {
        let expected = date("2000/01/01 00:00:00")

        XCTContext.runActivity(named: "UTC of startOfDay returns startOfDay when target is startOfDay") { _ in
            let result = Calendar.utc.startOfDay(for: date("2000/01/01 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "UTC of startOfDay returns startOfDay when target is same day") { _ in
            let result = Calendar.utc.startOfDay(for: date("2000/01/01 12:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "UTC of startOfDay does not return startOfDay when target is next day") { _ in
            let result = Calendar.utc.startOfDay(for: date("2000/01/02 00:00:00"))
            XCTAssertNotEqual(result, expected)
        }
    }

    func testStartOfYear() {
        let expected = date("2000/01/01 00:00:00")

        XCTContext.runActivity(named: "startOfYear returns startOfYear when target is startOfYear") { _ in
            let result = Calendar.utc.startOfYear(for: date("2000/01/01 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfYear returns startOfYear when target is same day") { _ in
            let result = Calendar.utc.startOfYear(for: date("2000/01/01 12:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfYear returns startOfYear when target is next day") { _ in
            let result = Calendar.utc.startOfYear(for: date("2000/01/02 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfYear returns startOfYear when target is next month") { _ in
            let result = Calendar.utc.startOfYear(for: date("2000/02/01 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfYear does not return startOfYear when target is next year") { _ in
            let result = Calendar.utc.startOfYear(for: date("2001/01/01 00:00:00"))
            XCTAssertNotEqual(result, expected)
        }
    }

    func testEndOfYear() {
        let expected = date("2000/12/31 23:59:59")

        XCTContext.runActivity(named: "endOfYear returns endOfYear when target is endOfYear") { _ in
            let result = Calendar.utc.endOfYear(for: date("2000/12/31 23:59:59"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfYear returns endOfYear when target is same day") { _ in
            let result = Calendar.utc.endOfYear(for: date("2000/12/31 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfYear returns endOfYear when target is last day") { _ in
            let result = Calendar.utc.endOfYear(for: date("2000/12/30 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfYear returns endOfYear when target is last month") { _ in
            let result = Calendar.utc.endOfYear(for: date("2000/11/30 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfYear does not return endOfYear when target is last year") { _ in
            let result = Calendar.utc.endOfYear(for: date("1999/12/31 00:00:00"))
            XCTAssertNotEqual(result, expected)
        }
    }

    func testStartOfMonth() {
        let expected = date("2000/01/01 00:00:00")

        XCTContext.runActivity(named: "startOfMonth returns startOfMonth when target is startOfMonth") { _ in
            let result = Calendar.utc.startOfMonth(for: date("2000/01/01 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfMonth returns startOfMonth when target is same day") { _ in
            let result = Calendar.utc.startOfMonth(for: date("2000/01/01 12:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfMonth returns startOfMonth when target is next day") { _ in
            let result = Calendar.utc.startOfMonth(for: date("2000/01/02 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "startOfMonth does not return startOfMonth when target is next month") { _ in
            let result = Calendar.utc.startOfMonth(for: date("2000/02/01 00:00:00"))
            XCTAssertNotEqual(result, expected)
        }
    }

    func testEndOfMonth() {
        let expected = date("2000/12/31 23:59:59")

        XCTContext.runActivity(named: "endOfMonth returns endOfMonth when target is endOfMonth") { _ in
            let result = Calendar.utc.endOfMonth(for: date("2000/12/31 23:59:59"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfMonth returns endOfMonth when target is same day") { _ in
            let result = Calendar.utc.endOfMonth(for: date("2000/12/31 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfMonth returns endOfMonth when target is last day") { _ in
            let result = Calendar.utc.endOfMonth(for: date("2000/12/30 00:00:00"))
            XCTAssertEqual(result, expected)
        }

        XCTContext.runActivity(named: "endOfYear does not return endOfYear when target is last month") { _ in
            let result = Calendar.utc.endOfMonth(for: date("2000/11/30 00:00:00"))
            XCTAssertNotEqual(result, expected)
        }
    }
}
