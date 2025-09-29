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

    /// Returns date bounds for the current `date` filter in UTC item space.
    fileprivate func predicateDateBounds() -> (start: Date, end: Date)? {
        switch date {
        case .none:
            return nil
        case .some(.before(let d)):
            let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
            let start = Date.distantPast
            let end = Calendar.utc.startOfDay(for: shifted) - 1
            return (start, end)
        case .some(.after(let d)):
            let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
            let start = Calendar.utc.startOfDay(for: shifted)
            let end = Date.distantFuture
            return (start, end)
        case .some(.sameYear(let d)):
            let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
            return (Calendar.utc.startOfYear(for: shifted), Calendar.utc.endOfYear(for: shifted))
        case .some(.sameMonth(let d)):
            let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
            return (Calendar.utc.startOfMonth(for: shifted), Calendar.utc.endOfMonth(for: shifted))
        case .some(.sameDay(let d)):
            let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
            return (Calendar.utc.startOfDay(for: shifted), Calendar.utc.endOfDay(for: shifted))
        }
    }

    /// In-memory evaluation to refine results beyond what SwiftData's macro allows.
    fileprivate func matches(_ item: Item) -> Bool {
        // Date filter (already applied in fetch when present, but keep as safety)
        if let bounds = predicateDateBounds() {
            if !(bounds.start <= item.date && item.date <= bounds.end) {
                return false
            }
        }
        // Content substring
        if let contentContains, !item.content.contains(contentContains) {
            return false
        }
        // Income range / non-zero
        if let min = incomeMin, !(min <= item.income) { return false }
        if let max = incomeMax, !(item.income <= max) { return false }
        if incomeNonZero, item.income == Decimal.zero { return false }
        // Outgo range / non-zero
        if let min = outgoMin, !(min <= item.outgo) { return false }
        if let max = outgoMax, !(item.outgo <= max) { return false }
        if outgoNonZero, item.outgo == Decimal.zero { return false }
        // Balance range
        if let min = balanceMin, !(min <= item.balance) { return false }
        if let max = balanceMax, !(item.balance <= max) { return false }
        // Repeat series
        if let repeatID, item.repeatID != repeatID { return false }
        return true
    }

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
        // Compute simple start/end date values to capture in the macro.
        var startOpt: Date?
        var endOpt: Date?
        if let date {
            switch date {
            case .before(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                startOpt = Date.distantPast
                endOpt = Calendar.utc.startOfDay(for: shifted) - 1
            case .after(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                startOpt = Calendar.utc.startOfDay(for: shifted)
                endOpt = Date.distantFuture
            case .sameYear(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                startOpt = Calendar.utc.startOfYear(for: shifted)
                endOpt = Calendar.utc.endOfYear(for: shifted)
            case .sameMonth(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                startOpt = Calendar.utc.startOfMonth(for: shifted)
                endOpt = Calendar.utc.endOfMonth(for: shifted)
            case .sameDay(let d):
                let shifted = Calendar.utc.shiftedDate(componentsFrom: d, in: .current)
                startOpt = Calendar.utc.startOfDay(for: shifted)
                endOpt = Calendar.utc.endOfDay(for: shifted)
            }
        }

        // Keep the SwiftData predicate simple to avoid macro limitations.
        guard let start = startOpt, let end = endOpt else {
            return #Predicate { _ in true }
        }
        return #Predicate { item in
            (start <= item.date) && (item.date <= end)
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
        // Fetch a superset using only date bounds (fast in-store filtering),
        // then refine in-memory to honor the full query.
        let descriptor: FetchDescriptor<Item>
        if let bounds = query.predicateDateBounds() {
            let start = bounds.start
            let end = bounds.end
            descriptor = .init(
                predicate: #Predicate { item in
                    (start <= item.date) && (item.date <= end)
                },
                sortBy: [
                    .init(\.date, order: order),
                    .init(\.content, order: order),
                    .init(\.persistentModelID, order: order)
                ]
            )
        } else {
            descriptor = .init(
                sortBy: [
                    .init(\.date, order: order),
                    .init(\.content, order: order),
                    .init(\.persistentModelID, order: order)
                ]
            )
        }
        let fetched = try context.fetch(descriptor)
        return fetched.filter { query.matches($0) }
    }
}
