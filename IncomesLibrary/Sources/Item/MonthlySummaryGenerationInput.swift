//
//  MonthlySummaryGenerationInput.swift
//  IncomesLibrary
//
//  Tracks deterministic inputs for monthly summary generation.
//

import Foundation
import SwiftData

/// Deterministic input signature for monthly summary generation.
public struct MonthlySummaryGenerationInput: Equatable, Sendable {
    /// Snapshot of an item field set that can affect generated summary content.
    public struct SourceSnapshot: Equatable, Sendable {
        /// Stable item identity represented as text for equality checks.
        public let id: String
        /// Item date used by summary queries.
        public let date: Date
        /// Item content text.
        public let content: String
        /// Item income amount.
        public let income: Decimal
        /// Item outgo amount.
        public let outgo: Decimal
        /// Display category name.
        public let category: String

        /// Creates a source snapshot.
        public init(
            id: String,
            date: Date,
            content: String,
            income: Decimal,
            outgo: Decimal,
            category: String
        ) {
            self.id = id
            self.date = date
            self.content = content
            self.income = income
            self.outgo = outgo
            self.category = category
        }
    }

    /// Current and previous month item snapshots.
    public let snapshots: [SourceSnapshot]
    /// Currency code selected for generation.
    public let currencyCode: String
    /// Locale identifier selected for generation.
    public let localeIdentifier: String

    /// Creates a deterministic input signature from item collections.
    public init(
        currentItems: [Item],
        previousItems: [Item],
        currencyCode: String,
        localeIdentifier: String
    ) {
        snapshots = currentItems.map(Self.snapshot(for:)) + previousItems.map(Self.snapshot(for:))
        self.currencyCode = currencyCode
        self.localeIdentifier = localeIdentifier
    }
}

private extension MonthlySummaryGenerationInput {
    static func snapshot(for item: Item) -> SourceSnapshot {
        .init(
            id: String(describing: item.persistentModelID),
            date: item.utcDate,
            content: item.content,
            income: item.income,
            outgo: item.outgo,
            category: CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            )
        )
    }
}
