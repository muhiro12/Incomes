//
//  ItemQuery.swift
//  IncomesLibrary
//
//  Composable query builder to centralize fetch-time filtering.
//

import Foundation
import SwiftData

/// Composable builder to express complex fetch-time filters for `Item`.
public struct ItemQuery: Sendable {
    /// Date-range filters based on a pivot date.
    public enum DateFilter: Sendable {
        /// Items strictly before the start of the given local day.
        case before(Date)
        /// Items on or after the start of the given local day.
        case after(Date)
        /// Items within the same local calendar year as the given date.
        case sameYear(Date)
        /// Items within the same local calendar month as the given date.
        case sameMonth(Date)
        /// Items within the same local calendar day as the given date.
        case sameDay(Date)
    }

    /// Optional date filter restriction.
    public var date: DateFilter?
    /// Substring match against `Item.content`.
    public var contentContains: String?

    /// Minimum income (inclusive) filter.
    public var incomeMin: Decimal?
    /// Maximum income (inclusive) filter.
    public var incomeMax: Decimal?
    /// Require income to be non-zero when `true`.
    public var incomeNonZero: Bool = false

    /// Minimum outgo (inclusive) filter.
    public var outgoMin: Decimal?
    /// Maximum outgo (inclusive) filter.
    public var outgoMax: Decimal?
    /// Require outgo to be non-zero when `true`.
    public var outgoNonZero: Bool = false

    /// Minimum balance (inclusive) filter.
    public var balanceMin: Decimal?
    /// Maximum balance (inclusive) filter.
    public var balanceMax: Decimal?

    /// Restrict to a specific repeat series.
    public var repeatID: UUID?

    /// Creates an empty query.
    public init() {}

    /// Materializes a `FetchDescriptor<Item>` from this query.
    /// - Parameter order: Sort order for the descriptor.
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

    /// Builds a SwiftData `Predicate<Item>` equivalent to this query.
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
    /// Fetches items using an `ItemQuery`.
    /// - Parameters:
    ///   - context: A `ModelContext` to query from.
    ///   - query: The composable query.
    ///   - order: Sort order (default: reverse).
    static func items(context: ModelContext, query: ItemQuery, order: SortOrder = .reverse) throws -> [Item] {
        try context.fetch(query.descriptor(order: order))
    }
}
