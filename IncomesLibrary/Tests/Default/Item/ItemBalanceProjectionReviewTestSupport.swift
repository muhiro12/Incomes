import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

/// Shared fixtures for the reviewed balance projection suites.
enum ItemBalanceProjectionReviewTestSupport {
    struct ItemState: Equatable {
        let utcDate: Date
        let content: String
        let income: Decimal
        let outgo: Decimal
        let balance: Decimal
    }

    static let rentOutgo: Decimal = 100
    static let movedRentOutgo = Decimal(string: "250.5") ?? .zero
    static let detachedRentOutgo = Decimal(string: "87.65") ?? .zero
    static let decoyAmount: Decimal = 40
    static let bonusIncome = Decimal(string: "1234.56") ?? .zero
    static let changedDraftOutgo: Decimal = 999

    static var rentInput: ItemFormInput {
        rentInput(
            isoString: "2000-01-01T12:00:00Z",
            outgo: rentOutgo
        )
    }

    static var movedRentInput: ItemFormInput {
        rentInput(
            isoString: "2000-02-05T12:00:00Z",
            outgo: movedRentOutgo
        )
    }

    static var changedDraftInput: ItemFormInput {
        rentInput(
            isoString: "2000-02-05T12:00:00Z",
            outgo: changedDraftOutgo
        )
    }

    static var detachedRentInput: ItemFormInput {
        rentInput(
            isoString: "2000-01-03T12:00:00Z",
            outgo: detachedRentOutgo
        )
    }

    static var decoyInput: ItemFormInput {
        .init(
            date: shiftedDate("2000-02-20T12:00:00Z"),
            content: "Decoy",
            income: decoyAmount,
            outgo: decoyAmount,
            category: "other",
            priority: 0
        )
    }

    static var bonusInput: ItemFormInput {
        .init(
            date: shiftedDate("2000-04-01T12:00:00Z"),
            content: "Bonus",
            income: bonusIncome,
            outgo: 0,
            category: "income",
            priority: 0
        )
    }

    static func createRent(
        context: ModelContext,
        repeatCount: Int
    ) throws {
        _ = try createItem(
            context: context,
            input: rentInput,
            repeatCount: repeatCount
        )
    }

    static func isSameDay(
        _ date: Date,
        _ isoString: String
    ) -> Bool {
        Calendar.current.isDate(
            date,
            inSameDayAs: shiftedDate(isoString)
        )
    }

    static func itemStates(
        _ context: ModelContext
    ) throws -> [ItemState] {
        try context.fetch(.items(.all, order: .forward)).map { item in
            .init(
                utcDate: item.utcDate,
                content: item.content,
                income: item.income,
                outgo: item.outgo,
                balance: item.balance
            )
        }
    }

    static func expectProjectionMatchesStore(
        context: ModelContext,
        review: ItemBalanceProjectionReview
    ) throws {
        let affectedDateRange = try #require(review.affectedDateRange)
        let storedMonthlyBalances = try monthlyBalances(
            context: context,
            from: affectedDateRange.lowerBound
        )
        #expect(review.comparison.projected.monthlyBalances == storedMonthlyBalances)
    }

    static func monthlyBalances(
        context: ModelContext,
        from date: Date
    ) throws -> [ItemBalanceProjectionOperations.MonthlyBalance] {
        let calendar = Calendar.current
        let items = try context.fetch(.items(.all, order: .forward)).filter { item in
            item.localDate >= date
        }
        var balancesByMonth = [Date: Decimal]()
        var orderedMonths = [Date]()
        items.forEach { item in
            let monthDate = calendar.startOfMonth(for: item.localDate)
            if balancesByMonth[monthDate] == nil {
                orderedMonths.append(monthDate)
            }
            balancesByMonth[monthDate] = item.balance
        }
        return orderedMonths.compactMap { monthDate in
            balancesByMonth[monthDate].map { balance in
                .init(
                    monthDate: monthDate,
                    balance: balance
                )
            }
        }
    }

    private static func rentInput(
        isoString: String,
        outgo: Decimal
    ) -> ItemFormInput {
        .init(
            date: shiftedDate(isoString),
            content: "Rent",
            income: 0,
            outgo: outgo,
            category: "housing",
            priority: 0
        )
    }
}
