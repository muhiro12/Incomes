//
//  ItemExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - FetchDescriptor

extension Item {
    typealias FetchDescriptor = SwiftData.FetchDescriptor<Item>
    typealias Predicate = Foundation.Predicate<Item>

    static func descriptor(predicate: Predicate? = .true, order: SortOrder = .reverse) -> FetchDescriptor {
        .init(predicate: predicate, sortBy: sortDescriptors(order: order))
    }

    static func descriptor(dateIsBetween start: Date, and end: Date, order: SortOrder = .reverse) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                start <= $0.date && $0.date <= end
            },
            order: order
        )
    }

    static func descriptor(dateIsAfter date: Date, order: SortOrder = .reverse) -> FetchDescriptor {
        descriptor(
            dateIsBetween: Calendar.utc.startOfDay(for: date),
            and: .distantFuture,
            order: order
        )
    }

    static func descriptor(dateIsBefore date: Date, order: SortOrder = .reverse) -> FetchDescriptor {
        descriptor(
            dateIsBetween: .distantPast,
            and: Calendar.utc.startOfDay(for: date).addingTimeInterval(-1),
            order: order
        )
    }

    static func descriptor(dateIsSameYearAs date: Date, order: SortOrder = .reverse) -> FetchDescriptor {
        descriptor(dateIsBetween: Calendar.utc.startOfYear(for: date),
                   and: Calendar.utc.endOfYear(for: date))
    }

    static func descriptor(dateIsSameMonthAs date: Date) -> FetchDescriptor {
        descriptor(dateIsBetween: Calendar.utc.startOfMonth(for: date),
                   and: Calendar.utc.endOfMonth(for: date))
    }

    static func descriptor(content: String, year: String) -> FetchDescriptor {
        guard let date = year.dateValueWithoutLocale(.yyyy) else {
            assertionFailure()
            return descriptor(predicate: .false)
        }
        let start = Calendar.utc.startOfYear(for: date)
        let end = Calendar.utc.endOfYear(for: date)
        return descriptor(
            predicate: #Predicate {
                $0.content == content
                    && start <= $0.date && $0.date <= end
            }
        )
    }

    static func descriptor(repeatIDIs repeatID: UUID) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                $0.repeatID == repeatID
            }
        )
    }

    static func descriptor(repeatIDIs repeatID: UUID, dateIsAfter date: Date) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                $0.repeatID == repeatID && $0.date >= date
            }
        )
    }
}

// MARK: - SortDescriptor

private extension Item {
    typealias SortDescriptor = Foundation.SortDescriptor<Item>

    static func sortDescriptors(order: SortOrder) -> [SortDescriptor] {
        [.init(\.date, order: order),
         .init(\.content, order: order),
         .init(\.persistentModelID, order: order)]
    }
}
