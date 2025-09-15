//
//  ItemPredicate.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

public enum ItemPredicate {
    case all
    case none
    // MARK: ID
    case idIs(PersistentIdentifier)
    case idsAre([PersistentIdentifier])
    // MARK: Tag
    case tagIs(Tag)
    case tagAndYear(tag: Tag, yearString: String)
    // MARK: Date
    case dateIsBefore(Date)
    case dateIsAfter(Date)
    case dateIsSameYearAs(Date)
    case dateIsSameMonthAs(Date)
    case dateIsSameDayAs(Date)
    // MARK: Content
    case contentContains(String)
    // MARK: - Income
    case incomeIsBetween(min: Decimal, max: Decimal)
    // MARK: Outgo
    case outgoIsBetween(min: Decimal, max: Decimal)
    case outgoIsGreaterThanOrEqualTo(amount: Decimal, onOrAfter: Date)
    // MARK: - Balance
    case balanceIsBetween(min: Decimal, max: Decimal)
    // MARK: RepeatID
    case repeatIDIs(UUID)
    case repeatIDAndDateIsAfter(repeatID: UUID, date: Date)

    var value: Predicate<Item> {
        switch self {
        case .all:
            return .true
        case .none:
            return .false

        // MARK: - ID

        case .idIs(let id):
            return #Predicate {
                $0.persistentModelID == id
            }

        case .idsAre(let ids):
            return #Predicate {
                ids.contains($0.persistentModelID)
            }

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
                let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
                let start = Calendar.utc.startOfYear(for: shiftedDate)
                let end = Calendar.utc.endOfYear(for: shiftedDate)
                return #Predicate {
                    start <= $0.date && $0.date <= end
                }
            case .yearMonth:
                guard let date = tag.name.dateValueWithoutLocale(.yyyyMM) else {
                    return .false
                }
                let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
                let start = Calendar.utc.startOfMonth(for: shiftedDate)
                let end = Calendar.utc.endOfMonth(for: shiftedDate)
                return #Predicate {
                    start <= $0.date && $0.date <= end
                }
            case .content:
                let content = tag.name
                return #Predicate {
                    $0.content == content
                }
            case .category:
                assertionFailure("Not Supported")
                return .false
            case .debug:
                assertionFailure("Not Supported")
                return .false
            }
        case .tagAndYear(let tag, let yearString):
            guard let tagType = tag.type,
                  let date = yearString.dateValueWithoutLocale(.yyyy) else {
                return .false
            }
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            switch tagType {
            case .content:
                let content = tag.name
                let start = Calendar.utc.startOfYear(for: shiftedDate)
                let end = Calendar.utc.endOfYear(for: shiftedDate)
                return #Predicate {
                    $0.content == content && start <= $0.date && $0.date <= end
                }
            case .year,
                 .yearMonth,
                 .category,
                 .debug:
                return Self.tagIs(tag).value
            }

        // MARK: - Date

        case .dateIsBefore(let date):
            let start = Date.distantPast
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let end = Calendar.utc.startOfDay(for: shiftedDate) - 1
            return #Predicate {
                start <= $0.date && $0.date <= end
            }
        case .dateIsAfter(let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfDay(for: shiftedDate)
            let end = Date.distantFuture
            return #Predicate {
                start <= $0.date && $0.date <= end
            }
        case .dateIsSameYearAs(let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfYear(for: shiftedDate)
            let end = Calendar.utc.endOfYear(for: shiftedDate)
            return #Predicate {
                start <= $0.date && $0.date <= end
            }
        case .dateIsSameMonthAs(let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfMonth(for: shiftedDate)
            let end = Calendar.utc.endOfMonth(for: shiftedDate)
            return #Predicate {
                start <= $0.date && $0.date <= end
            }
        case .dateIsSameDayAs(let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfDay(for: shiftedDate)
            let end = Calendar.utc.endOfDay(for: shiftedDate)
            return #Predicate {
                start <= $0.date && $0.date <= end
            }

        // MARK: - Content

        case .contentContains(let string):
            return #Predicate {
                $0.content.contains(string)
            }

        // MARK: - Income

        case .incomeIsBetween(let min, let max):
            return #Predicate {
                min <= $0.income && $0.income <= max
            }

        // MARK: - Outgo

        case .outgoIsBetween(let min, let max):
            return #Predicate {
                min <= $0.outgo && $0.outgo <= max
            }
        case .outgoIsGreaterThanOrEqualTo(let amount, let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfDay(for: shiftedDate)
            return #Predicate {
                $0.date >= start && $0.outgo >= amount
            }

        // MARK: - Balance

        case .balanceIsBetween(let min, let max):
            return #Predicate {
                min <= $0.balance && $0.balance <= max
            }

        // MARK: - RepeatID

        case .repeatIDIs(let repeatID):
            return #Predicate {
                $0.repeatID == repeatID
            }
        case .repeatIDAndDateIsAfter(let repeatID, let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfDay(for: shiftedDate)
            return #Predicate {
                $0.repeatID == repeatID && $0.date >= start
            }
        }
    }
}

extension ItemPredicate: Hashable {}

public extension FetchDescriptor where T == Item {
    static func items(_ predicate: ItemPredicate, order: SortOrder = .reverse) -> FetchDescriptor {
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
