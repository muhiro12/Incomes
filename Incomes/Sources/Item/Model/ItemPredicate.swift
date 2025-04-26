//
//  ItemPredicate.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

enum ItemPredicate {
    case all
    case none
    // MARK: Tag
    case tagIs(Tag)
    case tagAndYear(tag: Tag, yearString: String)
    // MARK: Date
    case dateIsBefore(Date)
    case dateIsAfter(Date)
    case dateIsSameYearAs(Date)
    case dateIsSameMonthAs(Date)
    case dateIsSameDayAs(Date)
    // MARK: Outgo
    case outgoIsGreaterThanOrEqualTo(amount: Decimal, onOrAfter: Date)
    // MARK: RepeatID
    case repeatIDIs(UUID)
    case repeatIDAndDateIsAfter(repeatID: UUID, date: Date)

    var value: Predicate<Item> {
        switch self {
        case .all:
            return .true
        case .none:
            return .false

        // MARK: - Tag

        case .tagIs(let tag):
            guard let tagType = tag.type else {
                return .false
            }
            switch tagType {
            case .year:
                guard let date = tag.name.dateValueWithoutLocale(.yyyy) else {
                    return .false
                }
                let start = Calendar.utc.startOfYear(for: date)
                let end = Calendar.utc.endOfYear(for: date)
                return #Predicate {
                    start <= $0.utcDate && $0.utcDate <= end
                }
            case .yearMonth:
                guard let date = tag.name.dateValueWithoutLocale(.yyyyMM) else {
                    return .false
                }
                let start = Calendar.utc.startOfMonth(for: date)
                let end = Calendar.utc.endOfMonth(for: date)
                return #Predicate {
                    start <= $0.utcDate && $0.utcDate <= end
                }
            case .content:
                let content = tag.name
                return #Predicate {
                    $0.content == content
                }
            case .category:
                assertionFailure("Not Supported")
                return .false
            }
        case .tagAndYear(let tag, let yearString):
            guard let tagType = tag.type,
                  let date = yearString.dateValueWithoutLocale(.yyyy) else {
                return .false
            }
            switch tagType {
            case .content:
                let content = tag.name
                let start = Calendar.utc.startOfYear(for: date)
                let end = Calendar.utc.endOfYear(for: date)
                return #Predicate {
                    $0.content == content && start <= $0.utcDate && $0.utcDate <= end
                }
            case .year,
                 .yearMonth,
                 .category:
                return Self.tagIs(tag).value
            }

        // MARK: - Date

        case .dateIsBefore(let date):
            let start = Date.distantPast
            let end = Calendar.utc.startOfDay(for: date) - 1
            return #Predicate {
                start <= $0.utcDate && $0.utcDate <= end
            }
        case .dateIsAfter(let date):
            let start = Calendar.utc.startOfDay(for: date)
            let end = Date.distantFuture
            return #Predicate {
                start <= $0.utcDate && $0.utcDate <= end
            }
        case .dateIsSameYearAs(let date):
            let start = Calendar.utc.startOfYear(for: date)
            let end = Calendar.utc.endOfYear(for: date)
            return #Predicate {
                start <= $0.utcDate && $0.utcDate <= end
            }
        case .dateIsSameMonthAs(let date):
            let start = Calendar.utc.startOfMonth(for: date)
            let end = Calendar.utc.endOfMonth(for: date)
            return #Predicate {
                start <= $0.utcDate && $0.utcDate <= end
            }
        case .dateIsSameDayAs(let date):
            let start = Calendar.utc.startOfDay(for: date)
            let end = Calendar.utc.endOfDay(for: date)
            return #Predicate {
                start <= $0.utcDate && $0.utcDate <= end
            }

        // MARK: - Outgo

        case .outgoIsGreaterThanOrEqualTo(let amount, let date):
            return #Predicate {
                $0.utcDate >= date && $0.outgo >= amount
            }

        // MARK: - RepeatID

        case .repeatIDIs(let repeatID):
            return #Predicate {
                $0.repeatID == repeatID
            }
        case .repeatIDAndDateIsAfter(let repeatID, let date):
            return #Predicate {
                $0.repeatID == repeatID && $0.utcDate >= date
            }
        }
    }
}

extension FetchDescriptor where T == Item {
    static func items(_ predicate: ItemPredicate, order: SortOrder = .reverse) -> FetchDescriptor {
        .init(
            predicate: predicate.value,
            sortBy: [
                .init(\.utcDate, order: order),
                .init(\.content, order: order),
                .init(\.persistentModelID, order: order)
            ]
        )
    }
}
