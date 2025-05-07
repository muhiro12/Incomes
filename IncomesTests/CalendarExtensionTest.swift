//
//  CalendarExtensionTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import Incomes
import Testing

@Suite(.serialized)
struct CalendarExtensionTest {
    // MARK: - utc

    @Test("UTC calendar should have zero offset", arguments: timeZones)
    func verifiesUTCCalendarTimeZone(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        #expect(calendar.timeZone.secondsFromGMT() == 0)
    }

    // MARK: - endOfDay

    @Test("endOfDay returns last second before next day", arguments: timeZones)
    func verifiesEndOfDay(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-03-15T10:30:00Z")
        let end = calendar.endOfDay(for: date)
        #expect(end == isoDate("2024-03-15T23:59:59Z"))
    }

    @Test("endOfDay returns Feb 29 23:59:59 UTC for 2024-02-29T15:00:00Z (JST Mar 1 00:00)", arguments: timeZones)
    func verifiesEndOfDayForUTCBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-02-29T15:00:00Z")  // JST: 3/1 00:00
        let end = calendar.endOfDay(for: date)
        #expect(end == isoDate("2024-02-29T23:59:59Z"))
    }

    @Test("endOfDay for 2024-02-29T23:59:59+0900 (JST) returns Feb 29 23:59:59 UTC", arguments: timeZones)
    func verifiesEndOfDayBeforeJSTBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-02-29T14:59:59Z")  // JST: 2/29 23:59:59
        let end = calendar.endOfDay(for: date)
        #expect(end == isoDate("2024-02-29T23:59:59Z"))
    }

    // MARK: - startOfMonth

    @Test("startOfMonth returns first day at 00:00:00", arguments: timeZones)
    func verifiesStartOfMonth(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-03-15T10:30:00Z")
        let start = calendar.startOfMonth(for: date)
        #expect(start == isoDate("2024-03-01T00:00:00Z"))
    }

    @Test("startOfMonth returns Feb 1 UTC for 2024-02-29T15:00:00Z (JST Mar 1 00:00)", arguments: timeZones)
    func verifiesStartOfMonthForUTCBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-02-29T15:00:00Z")  // JST: 3/1 00:00
        let start = calendar.startOfMonth(for: date)
        #expect(start == isoDate("2024-02-01T00:00:00Z"))
    }

    @Test("startOfMonth for 2024-02-29T23:59:59+0900 (JST) returns Feb 1 UTC", arguments: timeZones)
    func verifiesStartOfMonthBeforeJSTBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-02-29T14:59:59Z")  // JST: 2/29 23:59:59
        let start = calendar.startOfMonth(for: date)
        #expect(start == isoDate("2024-02-01T00:00:00Z"))
    }

    // MARK: - endOfMonth

    @Test("endOfMonth returns last day at 23:59:59", arguments: timeZones)
    func verifiesEndOfMonth(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-03-15T10:30:00Z")
        let end = calendar.endOfMonth(for: date)
        #expect(end == isoDate("2024-03-31T23:59:59Z"))
    }

    @Test("endOfMonth returns Mar 31 UTC for 2024-03-31T14:59:59Z (JST Mar 31 23:59:59)", arguments: timeZones)
    func verifiesEndOfMonthForUTCBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-03-31T14:59:59Z")  // JST: 3/31 23:59:59
        let end = calendar.endOfMonth(for: date)
        #expect(end == isoDate("2024-03-31T23:59:59Z"))
    }

    @Test("endOfMonth for 2024-02-29T23:59:59+0900 (JST) returns Feb 29 UTC", arguments: timeZones)
    func verifiesEndOfMonthBeforeJSTBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-02-29T14:59:59Z")  // JST: 2/29 23:59:59
        let end = calendar.endOfMonth(for: date)
        #expect(end == isoDate("2024-02-29T23:59:59Z"))
    }

    // MARK: - startOfYear

    @Test("startOfYear returns Jan 1st at 00:00:00", arguments: timeZones)
    func verifiesStartOfYear(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-03-15T10:30:00Z")
        let start = calendar.startOfYear(for: date)
        #expect(start == isoDate("2024-01-01T00:00:00Z"))
    }

    @Test("startOfYear returns Jan 1 2023 UTC for 2023-12-31T15:00:00Z (JST Jan 1 00:00)", arguments: timeZones)
    func verifiesStartOfYearForUTCBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2023-12-31T15:00:00Z")  // JST: 1/1 00:00
        let start = calendar.startOfYear(for: date)
        #expect(start == isoDate("2023-01-01T00:00:00Z"))
    }

    @Test("startOfYear for 2023-12-31T23:59:59+0900 (JST) returns Jan 1 2023 UTC", arguments: timeZones)
    func verifiesStartOfYearBeforeJSTBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2023-12-31T14:59:59Z")  // JST: 12/31 23:59:59
        let start = calendar.startOfYear(for: date)
        #expect(start == isoDate("2023-01-01T00:00:00Z"))
    }

    // MARK: - endOfYear

    @Test("endOfYear returns Dec 31st at 23:59:59", arguments: timeZones)
    func verifiesEndOfYear(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-03-15T10:30:00Z")
        let end = calendar.endOfYear(for: date)
        #expect(end == isoDate("2024-12-31T23:59:59Z"))
    }

    @Test("endOfYear returns Dec 31 2024 UTC for 2024-12-31T15:00:00Z (JST Jan 1 00:00)", arguments: timeZones)
    func verifiesEndOfYearForUTCBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-12-31T15:00:00Z")  // JST: 1/1 00:00
        let end = calendar.endOfYear(for: date)
        #expect(end == isoDate("2024-12-31T23:59:59Z"))
    }

    @Test("endOfYear for 2024-12-31T23:59:59+0900 (JST) returns Dec 31 2024 UTC", arguments: timeZones)
    func verifiesEndOfYearBeforeJSTBoundary(_ timeZone: TimeZone) {
        NSTimeZone.default = timeZone

        let calendar = Calendar.utc
        let date = isoDate("2024-12-31T14:59:59Z")  // JST: 12/31 23:59:59
        let end = calendar.endOfYear(for: date)
        #expect(end == isoDate("2024-12-31T23:59:59Z"))
    }
}
