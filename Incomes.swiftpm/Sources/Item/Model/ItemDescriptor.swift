//
//  ItemDescriptor.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

extension Item {
    enum Predicate {
        case all
        case none
        case dateIsBetween(start: Date, end: Date)
        case dateIsAfter(Date)
        case dateIsBefore(Date)
        case dateIsSameYearAs(Date)
        case dateIsSameMonthAs(Date)
        case contentAndYear(content: String, year: String)
        case repeatIDIs(UUID)
        case repeatIDAndDateIsAfter(repeatID: UUID, date: Date)

        var value: Foundation.Predicate<Item> {
            switch self {
            case .all:
                return .true
            case .none:
                return .false
            case .dateIsBetween(let start, let end):
                return #Predicate {
                    start <= $0.date && $0.date <= end
                }
            case .dateIsAfter(let date):
                return Self.dateIsBetween(
                    start: Calendar.utc.startOfDay(for: date),
                    end: Date.distantFuture
                ).value
            case .dateIsBefore(let date):
                return Self.dateIsBetween(
                    start: Date.distantPast,
                    end: Calendar.utc.startOfDay(for: date).addingTimeInterval(-1)
                ).value
            case .dateIsSameYearAs(let date):
                return Self.dateIsBetween(
                    start: Calendar.utc.startOfYear(for: date),
                    end: Calendar.utc.endOfYear(for: date)
                ).value
            case .dateIsSameMonthAs(let date):
                return Self.dateIsBetween(
                    start: Calendar.utc.startOfMonth(for: date),
                    end: Calendar.utc.endOfMonth(for: date)
                ).value
            case .contentAndYear(let content, let year):
                guard let date = year.dateValueWithoutLocale(.yyyy) else {
                    assertionFailure()
                    return .false
                }
                let start = Calendar.utc.startOfYear(for: date)
                let end = Calendar.utc.endOfYear(for: date)
                return #Predicate {
                    $0.content == content
                        && start <= $0.date && $0.date <= end
                }
            case .repeatIDIs(let repeatID):
                return #Predicate {
                    $0.repeatID == repeatID
                }
            case .repeatIDAndDateIsAfter(let repeatID, let date):
                return #Predicate {
                    $0.repeatID == repeatID && $0.date >= date
                }
            }
        }
    }

    static func descriptor(_ predicate: Predicate, order: SortOrder = .reverse) -> FetchDescriptor<Item> {
        .init(
            predicate: predicate.value,
            sortBy: [
                .init(\.date, order: order),
                .init(\.content, order: order),
                .init(\.persistentModelID, order: order)
            ]
        )
    }
}
