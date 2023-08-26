//
//  CalendarExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Calendar {
    static var current: Self {
        assertionFailure("Do not use current calendar")
        return .utc
    }

    static var utc: Self {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    func startOfYear(for date: Date) -> Date {
        let components = dateComponents([.year], from: date)
        guard let start = self.date(from: components) else {
            assertionFailure()
            return date
        }
        return start
    }

    func endOfYear(for date: Date) -> Date {
        guard let next = self.date(byAdding: .year, value: 1, to: date) else {
            assertionFailure()
            return date
        }
        return startOfYear(for: next) - 1
    }

    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        guard let start = self.date(from: components) else {
            assertionFailure()
            return date
        }
        return start
    }

    func endOfMonth(for date: Date) -> Date {
        guard let next = self.date(byAdding: .month, value: 1, to: date) else {
            assertionFailure()
            return date
        }
        return startOfMonth(for: next) - 1
    }
}
