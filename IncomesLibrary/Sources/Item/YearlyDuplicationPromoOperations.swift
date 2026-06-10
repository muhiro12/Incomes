import Foundation
import SwiftData

/// Operations for resolving yearly duplication promo state.
public enum YearlyDuplicationPromoOperations {
    /// Resolved yearly duplication promo proposal.
    public struct State {
        /// Suggested proposal group.
        public let proposal: YearlyItemDuplicationGroup
        /// Source year for the suggested duplication.
        public let sourceYear: Int
        /// Target year for the suggested duplication.
        public let targetYear: Int

        /// Creates a resolved yearly duplication promo state.
        public init(
            proposal: YearlyItemDuplicationGroup,
            sourceYear: Int,
            targetYear: Int
        ) {
            self.proposal = proposal
            self.sourceYear = sourceYear
            self.targetYear = targetYear
        }
    }

    /// Returns true when the yearly duplication promo should be considered.
    public static func shouldShow(
        date: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        shouldShow(
            date: date,
            randomValue: Int.random(in: 0..<Constants.randomUpperBound),
            calendar: calendar
        )
    }

    /// Returns true when the yearly duplication promo should be considered.
    public static func shouldShow(
        date: Date,
        randomValue: Int,
        calendar: Calendar = .current
    ) -> Bool {
        let month = calendar.component(.month, from: date)
        guard Constants.eligibleMonths.contains(month) else {
            return false
        }
        return randomValue == Constants.visibleRandomValue
    }

    /// Returns the first suggested yearly duplication promo state.
    public static func state(
        context: ModelContext,
        currentYear: Int = YearlyItemDuplicationSelectionOperations.currentYear()
    ) -> State? {
        state(
            context: context,
            currentYear: currentYear,
            minimumGroupCount: Constants.minimumGroupCount
        )
    }

    /// Returns the first suggested yearly duplication promo state.
    public static func state(
        context: ModelContext,
        currentYear: Int,
        minimumGroupCount: Int
    ) -> State? {
        let targetYears = YearlyItemDuplicationSelectionOperations.targetYears(
            currentYear: currentYear
        )
        guard
            let suggestion = try? YearlyItemDuplicationSelectionOperations.suggestion(
                context: context,
                targetYears: targetYears,
                minimumGroupCount: minimumGroupCount
            ),
            let proposal = suggestion.plan.groups.first
        else {
            return nil
        }
        return .init(
            proposal: proposal,
            sourceYear: suggestion.sourceYear,
            targetYear: suggestion.targetYear
        )
    }
}

private extension YearlyDuplicationPromoOperations {
    enum Constants {
        static let eligibleMonths: Set<Int> = [
            Month.january,
            Month.february,
            Month.november,
            Month.december
        ]
        static let minimumGroupCount = 3
        static let randomUpperBound = 3
        static let visibleRandomValue = 0
    }

    enum Month {
        static let january = 1
        static let february = 2
        static let november = 11
        static let december = 12
    }
}
