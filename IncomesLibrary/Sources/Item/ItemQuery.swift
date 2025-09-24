//
//  ItemQuery.swift
//  IncomesLibrary
//
//  Composable query builder to centralize fetch-time filtering.
//

import Foundation
import SwiftData

public struct ItemQuery: Sendable {
    public enum DateFilter: Sendable {
        case before(Date)
        case after(Date)
        case sameYear(Date)
        case sameMonth(Date)
        case sameDay(Date)
    }

    public var date: DateFilter?
    public var contentContains: String?

    public var incomeMin: Decimal?
    public var incomeMax: Decimal?
    public var incomeNonZero: Bool = false

    public var outgoMin: Decimal?
    public var outgoMax: Decimal?
    public var outgoNonZero: Bool = false

    public var balanceMin: Decimal?
    public var balanceMax: Decimal?

    public var repeatID: UUID?

    public init() {}

    public func descriptor(order: SortOrder = .reverse) -> FetchDescriptor<Item> {
        .init(
            predicate: predicate(),
            sortBy: [
                .init(\.date, order: order),
                .init(\.content, order: order),
                .init(\.persistentModelID, order: order)
            ]
        )
    }

    public func predicate() -> Predicate<Item> {
        // Pre-compute date bounds outside of #Predicate closure.
        let dateBounds: (start: Date, end: Date)? = {
            guard let date else {
                return nil
            }
            switch date {
            case .before(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                let start = Date.distantPast
                let end = Calendar.utc.startOfDay(for: shifted) - 1
                return (start, end)
            case .after(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                let start = Calendar.utc.startOfDay(for: shifted)
                let end = Date.distantFuture
                return (start, end)
            case .sameYear(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                return (Calendar.utc.startOfYear(for: shifted), Calendar.utc.endOfYear(for: shifted))
            case .sameMonth(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                return (Calendar.utc.startOfMonth(for: shifted), Calendar.utc.endOfMonth(for: shifted))
            case .sameDay(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                return (Calendar.utc.startOfDay(for: shifted), Calendar.utc.endOfDay(for: shifted))
            }
        }()

        let content = contentContains

        let incomeMin = incomeMin
        let incomeMax = incomeMax
        let incomeNonZero = incomeNonZero

        let outgoMin = outgoMin
        let outgoMax = outgoMax
        let outgoNonZero = outgoNonZero

        let balanceMin = balanceMin
        let balanceMax = balanceMax

        let repeatID = repeatID

        return #Predicate { item in
            // Date
            let dateOK: Bool = {
                guard let dateBounds else {
                    return true
                }
                return dateBounds.start <= item.date && item.date <= dateBounds.end
            }()

            // Content
            let contentOK: Bool = {
                guard let content else {
                    return true
                }
                return item.content.contains(content)
            }()

            // Income
            let incomeRangeOK: Bool = {
                switch (incomeMin, incomeMax) {
                case (nil, nil):
                    true
                case (let min?, nil):
                    min <= item.income
                case (nil, let max?):
                    item.income <= max
                case (let min?, let max?):
                    min <= item.income && item.income <= max
                }
            }()
            let incomeNonZeroOK: Bool = incomeNonZero ? (item.income != .zero) : true

            // Outgo
            let outgoRangeOK: Bool = {
                switch (outgoMin, outgoMax) {
                case (nil, nil):
                    true
                case (let min?, nil):
                    min <= item.outgo
                case (nil, let max?):
                    item.outgo <= max
                case (let min?, let max?):
                    min <= item.outgo && item.outgo <= max
                }
            }()
            let outgoNonZeroOK: Bool = outgoNonZero ? (item.outgo != .zero) : true

            // Balance
            let balanceRangeOK: Bool = {
                switch (balanceMin, balanceMax) {
                case (nil, nil):
                    true
                case (let min?, nil):
                    min <= item.balance
                case (nil, let max?):
                    item.balance <= max
                case (let min?, let max?):
                    min <= item.balance && item.balance <= max
                }
            }()

            // RepeatID
            let repeatOK: Bool = {
                guard let repeatID else {
                    return true
                }
                return item.repeatID == repeatID
            }()

            return dateOK && contentOK && incomeRangeOK && incomeNonZeroOK && outgoRangeOK && outgoNonZeroOK && balanceRangeOK && repeatOK
        }
    }
}

public extension ItemService {
    static func items(context: ModelContext, query: ItemQuery, order: SortOrder = .reverse) throws -> [Item] {
        try context.fetch(query.descriptor(order: order))
    }
}
