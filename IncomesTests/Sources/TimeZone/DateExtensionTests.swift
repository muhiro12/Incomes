//
//  DateExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import Incomes
import Testing

@Suite(.serialized)
struct DateExtensionTests {
    init() {
        NSTimeZone.default = .current
    }

    @Test
    func testStringValue() {
        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-01-01T12:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-01-01T21:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-12-31T00:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-12-31T12:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-12-31T15:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-12-31T21:00:00Z").stringValue(.yyyy)
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMM)
            #expect(result == "Jan 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMM)
            #expect(result == "Jan 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.MMMd)
            #expect(result == "Jan 1")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.MMMd)
            #expect(result == "Jan 1")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Jan 1, 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T12:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Jan 1, 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Jan 1, 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T21:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Jan 1, 2000")
        }

        do {
            let result = shiftedDate("2000-12-31T00:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Dec 31, 2000")
        }

        do {
            let result = shiftedDate("2000-12-31T12:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Dec 31, 2000")
        }

        do {
            let result = shiftedDate("2000-12-31T15:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Dec 31, 2000")
        }

        do {
            let result = shiftedDate("2000-12-31T21:00:00Z").stringValue(.yyyyMMMd)
            #expect(result == "Dec 31, 2000")
        }
    }

    @Test
    func testStringValueLondon() {
        NSTimeZone.default = .init(identifier: "Europe/London")!
        testStringValue()
    }

    @Test
    func testStringValueNewYork() {
        NSTimeZone.default = .init(identifier: "America/New_York")!
        testStringValue()
    }

    @Test
    func testStringValueTokyo() {
        NSTimeZone.default = .init(identifier: "Asia/Tokyo")!
        testStringValue()
    }

    @Test
    func testStringValueEn() {
        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyy, locale: .init(identifier: "en_US"))
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyy, locale: .init(identifier: "en_US"))
            #expect(result == "2000")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.MMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.MMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1, 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1, 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1, 2000")
        }

        do {
            let result = shiftedDate("2000-01-01T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Jan 1, 2000")
        }

        do {
            let result = shiftedDate("2000-12-31T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Dec 31, 2000")
        }

        do {
            let result = shiftedDate("2000-12-31T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Dec 31, 2000")
        }

        do {
            let result = shiftedDate("2000-12-31T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Dec 31, 2000")
        }

        do {
            let result = shiftedDate("2000-12-31T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "en_US"))
            #expect(result == "Dec 31, 2000")
        }
    }

    @Test
    func testStringValueJa() {
        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyy, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyy, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMM, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.MMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "1月1日")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.MMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "1月1日")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        do {
            let result = shiftedDate("2000-01-01T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        do {
            let result = shiftedDate("2000-01-01T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        do {
            let result = shiftedDate("2000-01-01T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        do {
            let result = shiftedDate("2000-01-01T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年1月1日")
        }

        do {
            let result = shiftedDate("2000-12-31T00:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年12月31日")
        }

        do {
            let result = shiftedDate("2000-12-31T12:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年12月31日")
        }

        do {
            let result = shiftedDate("2000-12-31T15:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年12月31日")
        }

        do {
            let result = shiftedDate("2000-12-31T21:00:00Z").stringValue(.yyyyMMMd, locale: .init(identifier: "ja_JP"))
            #expect(result == "2000年12月31日")
        }
    }
}
