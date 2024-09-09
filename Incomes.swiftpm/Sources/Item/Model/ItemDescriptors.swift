//
//  ItemDescriptors.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

extension Item {
    typealias FetchDescriptor = SwiftData.FetchDescriptor<Item>

    static func descriptor(sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: .true,
            sortBy: order
        )
    }

    static func descriptor(dateIsBetween start: Date, and end: Date, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                start <= $0.date && $0.date <= end
            },
            sortBy: order
        )
    }

    static func descriptor(dateIsAfter date: Date, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            dateIsBetween: Calendar.utc.startOfDay(for: date),
            and: .distantFuture,
            sortBy: order
        )
    }

    static func descriptor(dateIsBefore date: Date, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            dateIsBetween: .distantPast,
            and: Calendar.utc.startOfDay(for: date).addingTimeInterval(-1),
            sortBy: order
        )
    }

    static func descriptor(dateIsSameYearAs date: Date, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            dateIsBetween: Calendar.utc.startOfYear(for: date),
            and: Calendar.utc.endOfYear(for: date),
            sortBy: order
        )
    }

    static func descriptor(dateIsSameMonthAs date: Date, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            dateIsBetween: Calendar.utc.startOfMonth(for: date),
            and: Calendar.utc.endOfMonth(for: date),
            sortBy: order
        )
    }

    static func descriptor(content: String, year: String, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        guard let date = year.dateValueWithoutLocale(.yyyy) else {
            assertionFailure()
            return descriptor(predicate: .false, sortBy: order)
        }
        let start = Calendar.utc.startOfYear(for: date)
        let end = Calendar.utc.endOfYear(for: date)
        return descriptor(
            predicate: #Predicate {
                $0.content == content
                    && start <= $0.date && $0.date <= end
            },
            sortBy: order
        )
    }

    static func descriptor(repeatIDIs repeatID: UUID, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                $0.repeatID == repeatID
            },
            sortBy: order
        )
    }

    static func descriptor(repeatIDIs repeatID: UUID, dateIsAfter date: Date, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                $0.repeatID == repeatID && $0.date >= date
            },
            sortBy: order
        )
    }
}

// MARK: - Private

private extension Item {
    typealias Predicate = Foundation.Predicate<Item>

    static var defaultOrder = SortOrder.reverse

    static func descriptor(predicate: Predicate, sortBy order: SortOrder) -> FetchDescriptor {
        .init(
            predicate: predicate,
            sortBy: [
                .init(\.date, order: order),
                .init(\.content, order: order),
                .init(\.persistentModelID, order: order)
            ]
        )
    }
}
