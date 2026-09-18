import Foundation
import SwiftData

/// An immutable record of a balance projection the user explicitly reviewed.
///
/// A review pins the reviewed draft, the reviewed mutation target, and the stored
/// records the projection was calculated from, so the same proposal can be
/// revalidated immediately before it is applied.
public struct ItemBalanceProjectionReview: Equatable, Sendable {
    /// The mutation a reviewed projection describes.
    public enum Target: Equatable, Sendable {
        /// Creating an item in the given repeat months.
        case create(repeatMonthSelections: Set<RepeatMonthSelection>)
        /// Updating an existing item with the given repeat scope.
        case update(itemID: PersistentIdentifier, scope: ItemMutationScope)
    }

    /// Normalized draft values a projection was reviewed for.
    ///
    /// Values are normalized so that equivalent text entry, such as a different
    /// digit grouping, does not invalidate an otherwise unchanged review.
    public struct Draft: Equatable, Sendable {
        /// Local calendar date of the reviewed draft.
        public let date: Date
        /// Item description of the reviewed draft.
        public let content: String
        /// Income amount of the reviewed draft.
        public let income: Decimal
        /// Outgo amount of the reviewed draft.
        public let outgo: Decimal
        /// Stored category name of the reviewed draft.
        public let category: String
        /// Display priority of the reviewed draft.
        public let priority: Int

        /// Creates reviewed draft values.
        public init(
            date: Date,
            content: String,
            income: Decimal,
            outgo: Decimal,
            category: String,
            priority: Int
        ) {
            self.date = date
            self.content = content
            self.income = income
            self.outgo = outgo
            self.category = category
            self.priority = priority
        }
    }

    /// Identity and financially relevant values of one stored record.
    public struct RecordSignature: Equatable, Sendable {
        /// Stable identity of the record.
        public let itemID: PersistentIdentifier
        /// Repeat series the record belongs to.
        public let repeatID: UUID
        /// Persisted UTC date of the record.
        public let utcDate: Date
        /// Item description of the record.
        public let content: String
        /// Stored category name of the record.
        public let category: String
        /// Income amount of the record.
        public let income: Decimal
        /// Outgo amount of the record.
        public let outgo: Decimal
        /// Display priority of the record.
        public let priority: Int

        /// Creates a stored record signature.
        public init(
            itemID: PersistentIdentifier,
            repeatID: UUID,
            utcDate: Date,
            content: String,
            category: String,
            income: Decimal,
            outgo: Decimal,
            priority: Int
        ) {
            self.itemID = itemID
            self.repeatID = repeatID
            self.utcDate = utcDate
            self.content = content
            self.category = category
            self.income = income
            self.outgo = outgo
            self.priority = priority
        }
    }

    /// Stored records a projection was reviewed against.
    ///
    /// `records` covers every record used to calculate the projection, and
    /// `startingBalance` carries the running balance produced by all earlier
    /// records, so a change to any record the projection depends on is visible
    /// here even when it cancels out in the projected totals.
    public struct Baseline: Equatable, Sendable {
        /// Running balance immediately before the reviewed horizon.
        public let startingBalance: Decimal
        /// Records including predecessors, in a stable order.
        public let records: [RecordSignature]
        /// Records the reviewed mutation would change, in projection order.
        public let affectedRecords: [RecordSignature]

        /// Creates a reviewed baseline.
        public init(
            startingBalance: Decimal,
            records: [RecordSignature],
            affectedRecords: [RecordSignature]
        ) {
            self.startingBalance = startingBalance
            self.records = records
            self.affectedRecords = affectedRecords
        }
    }

    /// The reviewed mutation target.
    public let target: Target
    /// The reviewed draft values.
    public let draft: Draft
    /// The stored records the projection was calculated from.
    public let baseline: Baseline
    /// The reviewed balance comparison.
    public let comparison: ItemBalanceProjectionOperations.Comparison

    /// Repeat scope the review applies, or `nil` when the review covers a creation.
    public var scope: ItemMutationScope? {
        guard case let .update(_, scope) = target else {
            return nil
        }
        return scope
    }

    /// Number of records the reviewed mutation would create or update.
    public var changedItemCount: Int {
        comparison.projected.changedItemCount
    }

    /// Date range directly touched by the reviewed mutation.
    public var affectedDateRange: ClosedRange<Date>? {
        comparison.projected.affectedDateRange
    }

    /// Date range the reviewed projection covers.
    public var projectedDateRange: ClosedRange<Date>? {
        comparison.projected.dateRange
    }

    /// Creates a reviewed balance projection.
    public init(
        target: Target,
        draft: Draft,
        baseline: Baseline,
        comparison: ItemBalanceProjectionOperations.Comparison
    ) {
        self.target = target
        self.draft = draft
        self.baseline = baseline
        self.comparison = comparison
    }
}

extension ItemBalanceProjectionReview.Draft {
    init(storedValues: ItemStoredValues) {
        self.init(
            date: storedValues.date,
            content: storedValues.content,
            income: storedValues.income,
            outgo: storedValues.outgo,
            category: storedValues.category,
            priority: storedValues.priority
        )
    }
}
