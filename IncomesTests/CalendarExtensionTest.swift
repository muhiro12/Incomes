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

struct CalendarExtensionTest {
    // MARK: - utc

    @Test("UTC calendar should have zero offset")
    func verifiesUTCCalendarTimeZone() {
        let calendar = Calendar.utc
        #expect(calendar.timeZone.secondsFromGMT() == 0)
    }

    // MARK: - endOfDay

    @Test("endOfDay returns last second before next day")
    func verifiesEndOfDay() {
        let calendar = Calendar.utc
        let date = ISO8601DateFormatter().date(from: "2024-03-15T10:30:00Z")!
        let end = calendar.endOfDay(for: date)
        #expect(end == ISO8601DateFormatter().date(from: "2024-03-15T23:59:59Z")!)
    }

    // MARK: - startOfMonth

    @Test("startOfMonth returns first day at 00:00:00")
    func verifiesStartOfMonth() {
        let calendar = Calendar.utc
        let date = ISO8601DateFormatter().date(from: "2024-03-15T10:30:00Z")!
        let start = calendar.startOfMonth(for: date)
        #expect(start == ISO8601DateFormatter().date(from: "2024-03-01T00:00:00Z")!)
    }

    // MARK: - endOfMonth

    @Test("endOfMonth returns last day at 23:59:59")
    func verifiesEndOfMonth() {
        let calendar = Calendar.utc
        let date = ISO8601DateFormatter().date(from: "2024-03-15T10:30:00Z")!
        let end = calendar.endOfMonth(for: date)
        #expect(end == ISO8601DateFormatter().date(from: "2024-03-31T23:59:59Z")!)
    }

    // MARK: - startOfYear

    @Test("startOfYear returns Jan 1st at 00:00:00")
    func verifiesStartOfYear() {
        let calendar = Calendar.utc
        let date = ISO8601DateFormatter().date(from: "2024-03-15T10:30:00Z")!
        let start = calendar.startOfYear(for: date)
        #expect(start == ISO8601DateFormatter().date(from: "2024-01-01T00:00:00Z")!)
    }

    // MARK: - endOfYear

    @Test("endOfYear returns Dec 31st at 23:59:59")
    func verifiesEndOfYear() {
        let calendar = Calendar.utc
        let date = ISO8601DateFormatter().date(from: "2024-03-15T10:30:00Z")!
        let end = calendar.endOfYear(for: date)
        #expect(end == ISO8601DateFormatter().date(from: "2024-12-31T23:59:59Z")!)
    }
}
