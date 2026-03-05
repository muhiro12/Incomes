//
//  ItemPredicate.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//

import Foundation
import SwiftData

/// Discrete predicate presets for fetching items.
public enum ItemPredicate {
    /// Documented for SwiftLint compliance.
    case all
    /// Documented for SwiftLint compliance.
    case none // swiftlint:disable:this discouraged_none_name
    // MARK: ID
    /// Documented for SwiftLint compliance.
    case idIs(PersistentIdentifier)
    /// Documented for SwiftLint compliance.
    case idsAre([PersistentIdentifier])
    // MARK: Tag
    /// Documented for SwiftLint compliance.
    case tagIs(Tag)
    /// Documented for SwiftLint compliance.
    case tagAndYear(tag: Tag, yearString: String)
    // MARK: Date
    /// Documented for SwiftLint compliance.
    case dateIsBefore(Date)
    /// Documented for SwiftLint compliance.
    case dateIsAfter(Date)
    /// Documented for SwiftLint compliance.
    case dateIsSameYearAs(Date)
    /// Documented for SwiftLint compliance.
    case dateIsSameMonthAs(Date)
    /// Documented for SwiftLint compliance.
    case dateIsSameDayAs(Date)
    // MARK: Content
    /// Documented for SwiftLint compliance.
    case contentContains(String)
    // MARK: - Income
    /// Documented for SwiftLint compliance.
    case incomeIsBetween(min: Decimal, max: Decimal)
    /// Documented for SwiftLint compliance.
    case incomeIsNonZero
    // MARK: Outgo
    /// Documented for SwiftLint compliance.
    case outgoIsBetween(min: Decimal, max: Decimal)
    /// Documented for SwiftLint compliance.
    case outgoIsGreaterThanOrEqualTo(amount: Decimal, onOrAfter: Date)
    /// Documented for SwiftLint compliance.
    case outgoIsNonZero
    // MARK: - Balance
    /// Documented for SwiftLint compliance.
    case balanceIsBetween(min: Decimal, max: Decimal)
    // MARK: RepeatID
    /// Documented for SwiftLint compliance.
    case repeatIDIs(UUID)
    /// Documented for SwiftLint compliance.
    case repeatIDAndDateIsAfter(repeatID: UUID, date: Date)

    var value: Predicate<Item> {
        switch self {
        case .all:
            return .true
        case .none:
            return .false

        // MARK: - ID

        case .idIs(let id):
            return #Predicate { item in
                item.persistentModelID == id
            }

        case .idsAre(let ids):
            return #Predicate { item in
                ids.contains(item.persistentModelID)
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
                return #Predicate { item in
                    start <= item.date && item.date <= end
                }
            case .yearMonth:
                guard let date = tag.name.dateValueWithoutLocale(.yyyyMM) else {
                    return .false
                }
                let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
                let start = Calendar.utc.startOfMonth(for: shiftedDate)
                let end = Calendar.utc.endOfMonth(for: shiftedDate)
                return #Predicate { item in
                    start <= item.date && item.date <= end
                }
            case .content:
                let content = tag.name
                return #Predicate { item in
                    item.content == content
                }
            case .category:
                let itemIDs = tag.items?.map(\.id) ?? []
                return #Predicate { item in
                    itemIDs.contains(item.id)
                }
            case .debug:
                assertionFailure("Not Supported")
                return .false
            }
        case let .tagAndYear(tag, yearString):
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
                return #Predicate { item in
                    item.content == content && start <= item.date && item.date <= end
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
            return #Predicate { item in
                start <= item.date && item.date <= end
            }
        case .dateIsAfter(let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfDay(for: shiftedDate)
            let end = Date.distantFuture
            return #Predicate { item in
                start <= item.date && item.date <= end
            }
        case .dateIsSameYearAs(let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfYear(for: shiftedDate)
            let end = Calendar.utc.endOfYear(for: shiftedDate)
            return #Predicate { item in
                start <= item.date && item.date <= end
            }
        case .dateIsSameMonthAs(let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfMonth(for: shiftedDate)
            let end = Calendar.utc.endOfMonth(for: shiftedDate)
            return #Predicate { item in
                start <= item.date && item.date <= end
            }
        case .dateIsSameDayAs(let date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfDay(for: shiftedDate)
            let end = Calendar.utc.endOfDay(for: shiftedDate)
            return #Predicate { item in
                start <= item.date && item.date <= end
            }

        // MARK: - Content

        case .contentContains(let string):
            return #Predicate { item in
                item.content.contains(string)
            }

        // MARK: - Income

        case let .incomeIsBetween(min, max):
            return #Predicate { item in
                min <= item.income && item.income <= max
            }
        case .incomeIsNonZero:
            let zero: Decimal = .zero
            return #Predicate { item in
                item.income != zero
            }

        // MARK: - Outgo

        case let .outgoIsBetween(min, max):
            return #Predicate { item in
                min <= item.outgo && item.outgo <= max
            }
        case let .outgoIsGreaterThanOrEqualTo(amount, date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfDay(for: shiftedDate)
            return #Predicate { item in
                item.date >= start && item.outgo >= amount
            }
        case .outgoIsNonZero:
            let zero: Decimal = .zero
            return #Predicate { item in
                item.outgo != zero
            }

        // MARK: - Balance

        case let .balanceIsBetween(min, max):
            return #Predicate { item in
                min <= item.balance && item.balance <= max
            }

        // MARK: - RepeatID

        case .repeatIDIs(let repeatID):
            return #Predicate { item in
                item.repeatID == repeatID
            }
        case let .repeatIDAndDateIsAfter(repeatID, date):
            let shiftedDate = Calendar.utc.shiftedDate(componentsFrom: date, in: .current)
            let start = Calendar.utc.startOfDay(for: shiftedDate)
            return #Predicate { item in
                item.repeatID == repeatID && item.date >= start
            }
        }
    }
}

extension ItemPredicate: Hashable {}

public extension FetchDescriptor where T == Item {
    /// Convenience factory for a `FetchDescriptor<Item>` using an `ItemPredicate`.
    /// - Parameters:
    ///   - predicate: A preset predicate.
    ///   - order: Sort order (default: reverse).
    static func items(_ predicate: ItemPredicate, order: SortOrder = .reverse) -> FetchDescriptor {
        .init(
            predicate: predicate.value,
            sortBy: [
                .init(\.date, order: order),
                .init(\.priority, order: order == .forward ? .reverse : .forward),
                .init(\.content, order: order),
                .init(\.persistentModelID, order: order)
            ]
        )
    }
}
