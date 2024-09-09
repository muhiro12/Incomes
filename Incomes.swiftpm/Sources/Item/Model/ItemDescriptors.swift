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

    static func descriptor(order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: .true,
            order: order
        )
    }

    static func descriptor(dateIsBetween start: Date, and end: Date, order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                start <= $0.date && $0.date <= end
            },
            order: order
        )
    }

    static func descriptor(dateIsAfter date: Date, order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            dateIsBetween: Calendar.utc.startOfDay(for: date),
            and: .distantFuture,
            order: order
        )
    }

    static func descriptor(dateIsBefore date: Date, order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            dateIsBetween: .distantPast,
            and: Calendar.utc.startOfDay(for: date).addingTimeInterval(-1),
            order: order
        )
    }

    static func descriptor(dateIsSameYearAs date: Date, order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            dateIsBetween: Calendar.utc.startOfYear(for: date),
            and: Calendar.utc.endOfYear(for: date),
            order: order
        )
    }

    static func descriptor(dateIsSameMonthAs date: Date, order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            dateIsBetween: Calendar.utc.startOfMonth(for: date),
            and: Calendar.utc.endOfMonth(for: date),
            order: order
        )
    }

    static func descriptor(content: String, year: String, order: SortOrder = defaultOrder) -> FetchDescriptor {
        guard let date = year.dateValueWithoutLocale(.yyyy) else {
            assertionFailure()
            return descriptor(predicate: .false, order: order)
        }
        let start = Calendar.utc.startOfYear(for: date)
        let end = Calendar.utc.endOfYear(for: date)
        return descriptor(
            predicate: #Predicate {
                $0.content == content
                    && start <= $0.date && $0.date <= end
            },
            order: order
        )
    }

    static func descriptor(repeatIDIs repeatID: UUID, order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                $0.repeatID == repeatID
            },
            order: order
        )
    }

    static func descriptor(repeatIDIs repeatID: UUID, dateIsAfter date: Date, order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                $0.repeatID == repeatID && $0.date >= date
            },
            order: order
        )
    }
}

// MARK: - Private

private extension Item {
    typealias Predicate = Foundation.Predicate<Item>

    static var defaultOrder = SortOrder.reverse

    static func descriptor(predicate: Predicate, order: SortOrder) -> FetchDescriptor {
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
