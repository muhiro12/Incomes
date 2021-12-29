//
//  CalendarExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Calendar {
    func startOfYear(for date: Date) -> Date {
        let components = dateComponents([.year], from: date)
        guard let start = self.date(from: components) else {
            assertionFailure()
            return date
        }
        return start
    }

    func endOfYear(for date: Date) -> Date {
        guard let next = self.date(byAdding: .year, value: 1, to: date),
              let end = self.date(byAdding: .nanosecond, value: -1, to: startOfDay(for: next))
        else {
            assertionFailure()
            return date
        }
        return end
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
        guard let next = self.date(byAdding: .year, value: 1, to: date),
              let end = self.date(byAdding: .nanosecond, value: -1, to: startOfMonth(for: next))
        else {
            assertionFailure()
            return date
        }
        return end
    }
}
