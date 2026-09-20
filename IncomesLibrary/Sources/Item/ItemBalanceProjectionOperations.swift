import Foundation
import SwiftData

/// Domain operations for previewing item balance changes without saving them.
public enum ItemBalanceProjectionOperations {
    /// A projected balance summary for a proposed item mutation.
    public struct Projection: Equatable, Sendable {
        /// The date range covered by the projection.
        public let dateRange: ClosedRange<Date>?
        /// The date range directly touched by the proposed mutation.
        public let affectedDateRange: ClosedRange<Date>?
        /// Lowest projected running balance in the covered date range.
        public let minimumBalance: Decimal?
        /// First date whose projected running balance is negative.
        public let firstNegativeDate: Date?
        /// Last projected balance in the covered date range.
        public let latestBalance: Decimal?
        /// Last projected balance in each covered month.
        public let monthlyBalances: [MonthlyBalance]
        /// Number of item rows the proposed mutation would create or update.
        public let changedItemCount: Int

        /// True when the projected covered balance becomes negative.
        public var hasNegativeBalance: Bool {
            firstNegativeDate != nil
        }

        /// Creates a projected balance summary.
        public init(
            dateRange: ClosedRange<Date>?,
            affectedDateRange: ClosedRange<Date>?,
            minimumBalance: Decimal?,
            firstNegativeDate: Date?,
            latestBalance: Decimal?,
            monthlyBalances: [MonthlyBalance],
            changedItemCount: Int
        ) {
            self.dateRange = dateRange
            self.affectedDateRange = affectedDateRange
            self.minimumBalance = minimumBalance
            self.firstNegativeDate = firstNegativeDate
            self.latestBalance = latestBalance
            self.monthlyBalances = monthlyBalances
            self.changedItemCount = changedItemCount
        }
    }

    /// A balance comparison between the current plan and a proposed mutation.
    public struct Comparison: Equatable, Sendable {
        /// Current balance projection without the proposed mutation.
        public let current: Projection
        /// Balance projection after applying the proposed mutation.
        public let projected: Projection
        /// Per-month balance comparison over the covered date range.
        public let monthlyBalances: [MonthlyBalanceComparison]

        /// Difference between the projected and current latest balances.
        public var latestBalanceDifference: Decimal? {
            guard let currentBalance = current.latestBalance,
                  let projectedBalance = projected.latestBalance else {
                return nil
            }
            return projectedBalance - currentBalance
        }

        /// How the proposed change affects a negative balance in the covered range.
        public var negativeBalanceOutcome: NegativeBalanceOutcome {
            guard let projectedDate = projected.firstNegativeDate else {
                return .staysNonNegative
            }
            guard let currentDate = current.firstNegativeDate else {
                return .newlyNegative(date: projectedDate)
            }
            // An earlier first negative date means the change brings a deficit
            // forward even though the plan was already going negative.
            if projectedDate < currentDate {
                return .earlierNegative(date: projectedDate, currentDate: currentDate)
            }
            return .alreadyNegative(date: projectedDate)
        }

        /// Difference between the projected and current minimum balances.
        public var minimumBalanceDifference: Decimal? {
            guard let currentBalance = current.minimumBalance,
                  let projectedBalance = projected.minimumBalance else {
                return nil
            }
            return projectedBalance - currentBalance
        }

        /// Creates a balance comparison.
        public init(
            current: Projection,
            projected: Projection,
            monthlyBalances: [MonthlyBalanceComparison]
        ) {
            self.current = current
            self.projected = projected
            self.monthlyBalances = monthlyBalances
        }
    }

    /// A projected balance point for one month.
    public struct MonthlyBalance: Equatable, Sendable {
        /// Start date of the represented local-calendar month.
        public let monthDate: Date
        /// Last projected running balance in that month.
        public let balance: Decimal

        /// Creates a monthly projected balance point.
        public init(
            monthDate: Date,
            balance: Decimal
        ) {
            self.monthDate = monthDate
            self.balance = balance
        }
    }

    /// A projected month compared with the current saved plan.
    public struct MonthlyBalanceComparison: Equatable, Identifiable, Sendable {
        /// Start date of the represented local-calendar month.
        public let monthDate: Date
        /// Current balance at the end of the month.
        public let currentBalance: Decimal
        /// Projected balance at the end of the month.
        public let projectedBalance: Decimal

        /// Stable month identity.
        public var id: Date {
            monthDate
        }

        /// Difference between the projected and current month-end balances.
        public var difference: Decimal {
            projectedBalance - currentBalance
        }

        /// Creates a monthly balance comparison.
        public init(
            monthDate: Date,
            currentBalance: Decimal,
            projectedBalance: Decimal
        ) {
            self.monthDate = monthDate
            self.currentBalance = currentBalance
            self.projectedBalance = projectedBalance
        }
    }

    /// Previews balance changes that would be caused by creating an item.
    public static func previewCreate(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> Projection {
        try previewCreateComparison(
            context: context,
            input: input,
            repeatMonthSelections: repeatMonthSelections
        ).projected
    }

    /// Compares the current balance plan with a proposed item creation.
    public static func previewCreateComparison(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> Comparison {
        try ItemBalanceProjectionPlanner.previewCreateComparison(
            context: context,
            input: input,
            repeatMonthSelections: repeatMonthSelections
        )
    }

    /// Previews balance changes that would be caused by updating item(s).
    public static func previewUpdate(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> Projection {
        try previewUpdateComparison(
            context: context,
            item: item,
            input: input,
            scope: scope
        ).projected
    }

    /// Compares the current balance plan with a proposed item update.
    public static func previewUpdateComparison(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> Comparison {
        try ItemBalanceProjectionPlanner.previewUpdateComparison(
            context: context,
            item: item,
            input: input,
            scope: scope
        )
    }

    /// Reviews a proposed item creation so it can be applied without a second confirmation.
    public static func reviewCreate(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> ItemBalanceProjectionReview {
        try ItemBalanceProjectionPlanner.createReview(
            context: context,
            input: input,
            repeatMonthSelections: repeatMonthSelections
        )
    }

    /// Reviews a proposed item update so the reviewed scope can be applied later.
    public static func reviewUpdate(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> ItemBalanceProjectionReview {
        try ItemBalanceProjectionPlanner.updateReview(
            context: context,
            item: item,
            input: input,
            scope: scope
        )
    }

    /// Validates a reviewed creation against the current draft and stored records.
    ///
    /// Throws `ItemBalanceProjectionReviewError` when the reviewed proposal no longer applies.
    public static func validateCreateReview(
        context: ModelContext,
        review: ItemBalanceProjectionReview,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws {
        try ItemBalanceProjectionReviewValidator.validateCreateReview(
            context: context,
            review: review,
            input: input,
            repeatMonthSelections: repeatMonthSelections
        )
    }

    /// Validates a reviewed update and returns the reviewed repeat scope to apply.
    ///
    /// Throws `ItemBalanceProjectionReviewError` when the reviewed proposal no longer applies.
    public static func validateUpdateReview(
        context: ModelContext,
        review: ItemBalanceProjectionReview,
        item: Item,
        input: ItemFormInput
    ) throws -> ItemMutationScope {
        try ItemBalanceProjectionReviewValidator.validateUpdateReview(
            context: context,
            review: review,
            item: item,
            input: input
        )
    }
}
