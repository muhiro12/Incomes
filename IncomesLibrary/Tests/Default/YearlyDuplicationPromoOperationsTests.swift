import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct YearlyDuplicationPromoOperationsTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func shouldShow_returns_true_for_eligible_month_and_visible_random_value() {
        #expect(
            YearlyDuplicationPromoOperations.shouldShow(
                date: TestValue.eligibleDate,
                randomValue: TestValue.visibleRandomValue,
                calendar: TestValue.calendar
            )
        )
    }

    @Test
    func shouldShow_returns_false_for_ineligible_month() {
        #expect(
            !YearlyDuplicationPromoOperations.shouldShow(
                date: TestValue.ineligibleDate,
                randomValue: TestValue.visibleRandomValue,
                calendar: TestValue.calendar
            )
        )
    }

    @Test
    func shouldShow_returns_false_for_hidden_random_value() {
        #expect(
            !YearlyDuplicationPromoOperations.shouldShow(
                date: TestValue.eligibleDate,
                randomValue: TestValue.hiddenRandomValue,
                calendar: TestValue.calendar
            )
        )
    }

    @Test
    func state_returns_first_suggested_proposal() throws {
        try createRepeatItems()

        let state = try #require(
            YearlyDuplicationPromoOperations.state(
                context: context,
                currentYear: TestValue.targetYear,
                minimumGroupCount: TestValue.minimumGroupCount
            )
        )

        #expect(state.sourceYear == TestValue.sourceYear)
        #expect(state.targetYear == TestValue.targetYear)
        #expect(state.proposal.content == "Rent")
        #expect(state.proposal.entryCount == TestValue.repeatCount)
    }
}

private extension YearlyDuplicationPromoOperationsTests {
    enum TestValue {
        static var calendar: Calendar {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: .zero) ?? .current
            return calendar
        }

        static let eligibleDate = isoDate("2025-11-01T00:00:00Z")
        static let ineligibleDate = isoDate("2025-06-01T00:00:00Z")
        static let visibleRandomValue = 0
        static let hiddenRandomValue = 1
        static let sourceYear = 2_024
        static let targetYear = 2_025
        static let outgo: Decimal = 100
        static let repeatCount = 3
        static let minimumGroupCount = 1
    }

    func createRepeatItems() throws {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate("\(TestValue.sourceYear)-01-10T12:00:00Z"),
                content: "Rent",
                income: .zero,
                outgo: TestValue.outgo,
                category: "Housing",
                priority: .zero
            ),
            repeatCount: TestValue.repeatCount
        )
    }
}
