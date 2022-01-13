//
//  DateExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes

class DateExtensionTests: XCTestCase {
    func testStringValue() {
        XCTContext.runActivity(named: "yyyy in current is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.yyyy)
            XCTAssertEqual(result, "1970")
        }

        XCTContext.runActivity(named: "yyyy in en is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.yyyy, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "1970")
        }

        XCTContext.runActivity(named: "yyyy in en ja as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.yyyy, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "1970年")
        }

        XCTContext.runActivity(named: "yyyyMMM in current is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.yyyyMMM)
            XCTAssertEqual(result, "Jan 1970")
        }

        XCTContext.runActivity(named: "yyyyMMM in en is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.yyyyMMM, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 1970")
        }

        XCTContext.runActivity(named: "yyyyMMM in ja is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.yyyyMMM, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "1970年1月")
        }

        XCTContext.runActivity(named: "MMMd in current is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.MMMd)
            XCTAssertEqual(result, "Jan 1")
        }

        XCTContext.runActivity(named: "MMMd in en is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.MMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 1")
        }

        XCTContext.runActivity(named: "MMMd in ja is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.MMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "1月1日")
        }

        XCTContext.runActivity(named: "yyyyMMMd in current is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.yyyyMMMd)
            XCTAssertEqual(result, "Jan 1, 1970")
        }

        XCTContext.runActivity(named: "yyyyMMMd in en is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            XCTAssertEqual(result, "Jan 1, 1970")
        }

        XCTContext.runActivity(named: "yyyyMMMd in ja is as expected") { _ in
            let result = Date(timeIntervalSince1970: 0).stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            XCTAssertEqual(result, "1970年1月1日")
        }
    }
}
