//
//  DateExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

@testable import Incomes
import XCTest

final class DateExtensionTests: XCTestCase {
    override func setUp() {
        NSTimeZone.default = .current
    }

    override func tearDown() {
        NSTimeZone.default = .current
    }

    func testStringValue() {
        XCTContext.runActivity(named: "yyyy is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyy)
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyy at 12:00 is as expected") { _ in
            let result = isoDate("2000-01-01T12:00:00Z").stringValue(.yyyy)
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyy at 15:00 is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyy)
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyy at 21:00 is as expected") { _ in
            let result = isoDate("2000-01-01T21:00:00Z").stringValue(.yyyy)
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyy at 12-31 is as expected") { _ in
            let result = isoDate("2000-12-31T00:00:00Z").stringValue(.yyyy)
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyy at 12:00, 12-31 is as expected") { _ in
            let result = isoDate("2000-12-31T12:00:00Z").stringValue(.yyyy)
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyy at 15:00, 12-31 is as expected") { _ in
            let result = isoDate("2000-12-31T15:00:00Z").stringValue(.yyyy)
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyy at 21:00, 12-31 is as expected") { _ in
            let result = isoDate("2000-12-31T21:00:00Z").stringValue(.yyyy)
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyyMMM is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMM)
            XCTAssertEqual(result, "Jan 2000")
        }

        XCTContext.runActivity(named: "yyyyMMM at 15:00 is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMM)
            XCTAssertEqual(result, "Jan 2000")
        }

        XCTContext.runActivity(named: "MMMd is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.MMMd)
            XCTAssertEqual(result, "Jan 1")
        }

        XCTContext.runActivity(named: "MMMd at 15:00 is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.MMMd)
            XCTAssertEqual(result, "Jan 1")
        }

        XCTContext.runActivity(named: "yyyyMMMd is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd)
            XCTAssertEqual(result, "Jan 1, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 12:00 is as expected") { _ in
            let result = isoDate("2000-01-01T12:00:00Z").stringValue(.yyyyMMMd)
            XCTAssertEqual(result, "Jan 1, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 15:00 as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd)
            XCTAssertEqual(result, "Jan 1, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 21:00 is as expected") { _ in
            let result = isoDate("2000-01-01T21:00:00Z").stringValue(.yyyyMMMd)
            XCTAssertEqual(result, "Jan 1, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 12-31 is as expected") { _ in
            let result = isoDate("2000-12-31T00:00:00Z").stringValue(.yyyyMMMd)
            XCTAssertEqual(result, "Dec 31, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 12:00, 12-31 is as expected") { _ in
            let result = isoDate("2000-12-31T12:00:00Z").stringValue(.yyyyMMMd)
            XCTAssertEqual(result, "Dec 31, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 15:00, 12-31 is as expected") { _ in
            let result = isoDate("2000-12-31T15:00:00Z").stringValue(.yyyyMMMd)
            XCTAssertEqual(result, "Dec 31, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 21:00, 12-31 is as expected") { _ in
            let result = isoDate("2000-12-31T21:00:00Z").stringValue(.yyyyMMMd)
            XCTAssertEqual(result, "Dec 31, 2000")
        }
    }

    func testStringValueLondon() {
        NSTimeZone.default = .init(identifier: "Europe/London")!
        testStringValue()
    }

    func testStringValueNewYork() {
        NSTimeZone.default = .init(identifier: "America/New_York")!
        testStringValue()
    }

    func testStringValueTokyo() {
        NSTimeZone.default = .init(identifier: "Asia/Tokyo")!
        testStringValue()
    }

    func testStringValueEn() {
        XCTContext.runActivity(named: "yyyy in en is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyy, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyy at 15:00 in en is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyy, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "2000")
        }

        XCTContext.runActivity(named: "yyyyMMM in en is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 2000")
        }

        XCTContext.runActivity(named: "yyyyMMM at 15:00 in en is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 2000")
        }

        XCTContext.runActivity(named: "MMMd in en is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.MMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 1")
        }

        XCTContext.runActivity(named: "MMMd at 15:00 in en is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.MMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 1")
        }

        XCTContext.runActivity(named: "yyyyMMMd in en is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 1, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 12:00 in en is as expected") { _ in
            let result = isoDate("2000-01-01T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 1, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 15:00 in en is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 1, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 21:00 in en is as expected") { _ in
            let result = isoDate("2000-01-01T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 1, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 12-31 in en is as expected") { _ in
            let result = isoDate("2000-12-31T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Dec 31, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 12:00, 12-31 in en is as expected") { _ in
            let result = isoDate("2000-12-31T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Dec 31, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 15:00, 12-31 in en is as expected") { _ in
            let result = isoDate("2000-12-31T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Dec 31, 2000")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 21:00, 12-31 in en is as expected") { _ in
            let result = isoDate("2000-12-31T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Dec 31, 2000")
        }
    }

    func testStringValueJa() {
        XCTContext.runActivity(named: "yyyy in ja as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyy, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年")
        }

        XCTContext.runActivity(named: "yyyy at 15:00 in ja as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyy, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年")
        }

        XCTContext.runActivity(named: "yyyyMMM in ja is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年1月")
        }

        XCTContext.runActivity(named: "yyyyMMM at 15:00 in ja is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年1月")
        }

        XCTContext.runActivity(named: "MMMd in ja is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.MMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "1月1日")
        }

        XCTContext.runActivity(named: "MMMd at 15:00 in ja is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.MMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "1月1日")
        }

        XCTContext.runActivity(named: "yyyyMMMd in ja is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年1月1日")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 15:00 in ja is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年1月1日")
        }

        XCTContext.runActivity(named: "yyyyMMMd in ja is as expected") { _ in
            let result = isoDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年1月1日")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 12:00 in ja is as expected") { _ in
            let result = isoDate("2000-01-01T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年1月1日")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 15:00 in ja is as expected") { _ in
            let result = isoDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年1月1日")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 21:00 in ja is as expected") { _ in
            let result = isoDate("2000-01-01T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年1月1日")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 12-31 in ja is as expected") { _ in
            let result = isoDate("2000-12-31T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年12月31日")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 12:00, 12-31 in ja is as expected") { _ in
            let result = isoDate("2000-12-31T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年12月31日")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 15:00, 12-31 in ja is as expected") { _ in
            let result = isoDate("2000-12-31T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年12月31日")
        }

        XCTContext.runActivity(named: "yyyyMMMd at 21:00, 12-31 in ja is as expected") { _ in
            let result = isoDate("2000-12-31T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "2000年12月31日")
        }
    }
}
