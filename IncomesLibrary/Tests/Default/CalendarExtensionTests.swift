//
//  CalendarExtensionTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import Incomes
import Testing

struct CalendarExtensionTests {
    struct StartOfDayUTCTests {
        @Test("UTC of startOfDay returns startOfDay when target is startOfDay")
        func whenStartOfDay() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfDay(for: isoDate("2000-01-01T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("UTC of startOfDay returns startOfDay when target is same day")
        func whenSameDay() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfDay(for: isoDate("2000-01-01T12:00:00Z"))
            #expect(result == expected)
        }

        @Test("UTC of startOfDay does not return startOfDay when target is next day")
        func whenNextDay() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfDay(for: isoDate("2000-01-02T00:00:00Z"))
            #expect(result != expected)
        }
    }

    struct EndOfDayTests {
        @Test("endOfDay returns endOfDay when target is endOfDay")
        func whenEndOfDay() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T23:59:59Z"))
            #expect(result == expected)
        }

        @Test("endOfDay returns endOfDay when target is same day")
        func whenSameDay() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("endOfDay does not return endOfDay when target is last day")
        func whenLastDay() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-11-30T00:00:00Z"))
            #expect(result != expected)
        }
    }

    struct StartOfMonthTests {
        @Test("startOfMonth returns startOfMonth when target is startOfMonth")
        func whenStartOfMonth() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-01-01T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("startOfMonth returns startOfMonth when target is same day")
        func whenSameDay() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-01-01T12:00:00Z"))
            #expect(result == expected)
        }

        @Test("startOfMonth returns startOfMonth when target is next day")
        func whenNextDay() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-01-02T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("startOfMonth does not return startOfMonth when target is next month")
        func whenNextMonth() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-02-01T00:00:00Z"))
            #expect(result != expected)
        }
    }

    struct EndOfMonthTests {
        @Test("endOfMonth returns endOfMonth when target is endOfMonth")
        func whenEndOfMonth() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T23:59:59Z"))
            #expect(result == expected)
        }

        @Test("endOfMonth returns endOfMonth when target is same day")
        func whenSameDay() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("endOfMonth returns endOfMonth when target is last day")
        func whenLastDay() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-30T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("endOfMonth does not return endOfMonth when target is last month")
        func whenLastMonth() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-11-30T00:00:00Z"))
            #expect(result != expected)
        }
    }

    struct StartOfYearTests {
        @Test("startOfYear returns startOfYear when target is startOfYear")
        func whenStartOfYear() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfYear(for: isoDate("2000-01-01T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("startOfYear returns startOfYear when target is same day")
        func whenSameDay() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfYear(for: isoDate("2000-01-01T12:00:00Z"))
            #expect(result == expected)
        }

        @Test("startOfYear returns startOfYear when target is next day")
        func whenNextDay() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfYear(for: isoDate("2000-01-02T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("startOfYear returns startOfYear when target is next month")
        func whenNextMonth() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfYear(for: isoDate("2000-02-01T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("startOfYear does not return startOfYear when target is next year")
        func whenNextYear() {
            let expected = isoDate("2000-01-01T00:00:00Z")
            let result = Calendar.utc.startOfYear(for: isoDate("2001-01-01T00:00:00Z"))
            #expect(result != expected)
        }
    }

    struct EndOfYearTests {
        @Test("endOfYear returns endOfYear when target is endOfYear")
        func whenEndOfYear() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfYear(for: isoDate("2000-12-31T23:59:59Z"))
            #expect(result == expected)
        }

        @Test("endOfYear returns endOfYear when target is same day")
        func whenSameDay() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfYear(for: isoDate("2000-12-31T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("endOfYear returns endOfYear when target is last day")
        func whenLastDay() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfYear(for: isoDate("2000-12-30T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("endOfYear returns endOfYear when target is last month")
        func whenLastMonth() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfYear(for: isoDate("2000-11-30T00:00:00Z"))
            #expect(result == expected)
        }

        @Test("endOfYear does not return endOfYear when target is last year")
        func whenLastYear() {
            let expected = isoDate("2000-12-31T23:59:59Z")
            let result = Calendar.utc.endOfYear(for: isoDate("1999-12-31T00:00:00Z"))
            #expect(result != expected)
        }
    }
}
