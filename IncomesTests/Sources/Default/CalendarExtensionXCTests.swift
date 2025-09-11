//
//  CalendarExtensionXCTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import Incomes
import Testing

struct CalendarExtensionXCTests {
    @Test
    func testUtc() {
        let expected = isoDate("2000-01-01T00:00:00Z")

        do {
            let result = Calendar.utc.startOfDay(for: isoDate("2000-01-01T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.startOfDay(for: isoDate("2000-01-01T12:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.startOfDay(for: isoDate("2000-01-02T00:00:00Z"))
            #expect(result != expected)
        }
    }

    @Test
    func testEndOfDay() {
        let expected = isoDate("2000-12-31T23:59:59Z")

        do {
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T23:59:59Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-11-30T00:00:00Z"))
            #expect(result != expected)
        }
    }

    @Test
    func testStartOfMonth() {
        let expected = isoDate("2000-01-01T00:00:00Z")

        do {
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-01-01T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-01-01T12:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-01-02T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.startOfMonth(for: isoDate("2000-02-01T00:00:00Z"))
            #expect(result != expected)
        }
    }

    @Test
    func testEndOfMonth() {
        let expected = isoDate("2000-12-31T23:59:59Z")

        do {
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T23:59:59Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-31T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-12-30T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.endOfMonth(for: isoDate("2000-11-30T00:00:00Z"))
            #expect(result != expected)
        }
    }

    @Test
    func testStartOfYear() {
        let expected = isoDate("2000-01-01T00:00:00Z")

        do {
            let result = Calendar.utc.startOfYear(for: isoDate("2000-01-01T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.startOfYear(for: isoDate("2000-01-01T12:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.startOfYear(for: isoDate("2000-01-02T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.startOfYear(for: isoDate("2000-02-01T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.startOfYear(for: isoDate("2001-01-01T00:00:00Z"))
            #expect(result != expected)
        }
    }

    @Test
    func testEndOfYear() {
        let expected = isoDate("2000-12-31T23:59:59Z")

        do {
            let result = Calendar.utc.endOfYear(for: isoDate("2000-12-31T23:59:59Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.endOfYear(for: isoDate("2000-12-31T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.endOfYear(for: isoDate("2000-12-30T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.endOfYear(for: isoDate("2000-11-30T00:00:00Z"))
            #expect(result == expected)
        }

        do {
            let result = Calendar.utc.endOfYear(for: isoDate("1999-12-31T00:00:00Z"))
            #expect(result != expected)
        }
    }
}
