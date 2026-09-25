import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct ItemAmountBoundaryTests {
    private let english = Locale(identifier: "en_US")
    private let largestSupportedText = String(repeating: "9", count: AmountPrecision.maximumSignificantDigits)
    private let sourceYear = 2_024
    private let targetYear = 2_025
    private let firstMonthOfYear = 1
    private let firstDayOfMonth = 1

    @Test("Negative and extreme supported amounts reopen with the exact stored value")
    func supported_amounts_reopen_with_exact_value() throws {
        let significand = String("12345678912345678912".prefix(AmountPrecision.maximumSignificantDigits))
        let expectedAmounts: [(income: Decimal, outgo: Decimal)] = [
            (try #require(Decimal(string: "-1234.56")), try #require(Decimal(string: "-0.01"))),
            (try #require(Decimal(string: largestSupportedText)), .zero),
            (try #require(Decimal(string: "0." + significand)), try #require(Decimal(string: significand + "000")))
        ]

        try withTemporaryStoreURL { url in
            try seedAmounts(expectedAmounts, at: url)
            try verifyReopenedAmounts(expectedAmounts, at: url)
        }
    }

    @Test("An existing extreme record can be edited without changing its amount")
    func existing_extreme_record_keeps_amount_when_edited() throws {
        let context = testContext
        let expectedIncome = try #require(Decimal(string: largestSupportedText))
        let item = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2025-03-10T12:00:00Z"),
                content: "Original",
                income: expectedIncome,
                outgo: .zero,
                category: "Boundary",
                priority: 0,
                locale: english
            )
        )

        let reopenedInput = ItemFormInput(item: item, locale: english)
        #expect(reopenedInput.isValid)
        #expect(reopenedInput.income == expectedIncome)

        try updateItem(
            context: context,
            item: item,
            input: .init(
                date: reopenedInput.date,
                content: "Renamed",
                incomeText: reopenedInput.incomeText,
                outgoText: reopenedInput.outgoText,
                category: reopenedInput.category,
                priorityText: reopenedInput.priorityText
            )
        )

        #expect(item.content == "Renamed")
        #expect(item.income == expectedIncome)
    }

    @Test("Amounts that cannot be stored exactly are rejected with a specific error")
    func unsupported_amounts_are_rejected() {
        let unsupportedIncome = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: largestSupportedText + "9",
            outgoText: "",
            category: "Boundary",
            priorityText: "0"
        )
        #expect(throws: ItemFormInput.ValidationError.unsupportedIncome) {
            try unsupportedIncome.validate()
        }

        let unsupportedOutgo = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "",
            outgoText: "1" + String(repeating: "0", count: 200),
            category: "Boundary",
            priorityText: "0"
        )
        #expect(throws: ItemFormInput.ValidationError.unsupportedOutgo) {
            try unsupportedOutgo.validate()
        }

        let notANumber = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "abc",
            outgoText: "",
            category: "Boundary",
            priorityText: "0"
        )
        #expect(throws: ItemFormInput.ValidationError.invalidIncome) {
            try notANumber.validate()
        }
    }

    @Test("A running balance beyond the decimal range is refused, not stored as NaN")
    func balance_beyond_decimal_range_is_refused() throws {
        let context = testContext
        // An amount this large cannot be entered, but a legacy record could hold
        // one, and recalculation must not write a non-finite balance.
        for offset in 0..<2 {
            _ = try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2025-0\(offset + 4)-10T12:00:00Z"),
                    content: "Legacy \(offset)",
                    income: .greatestFiniteMagnitude,
                    outgo: .zero,
                    category: "Boundary",
                    priority: 0
                ),
                repeatID: UUID()
            )
        }

        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try BalanceCalculator.calculate(in: context, after: .distantPast)
        }
        #expect(fetchItems(context).allSatisfy { item in
            !item.balance.isNaN
        })
    }

    @Test("Inexact balance calculations are refused before writing any balance",
          arguments: ["1e60", "999999999999999"])
    func inexact_balances_are_refused(largeText: String) throws {
        let context = testContext
        let large = try #require(Decimal(string: largeText))
        var items = [Item]()
        for (index, income) in [large, Decimal(2)].enumerated() {
            let item = try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2025-0\(index + 4)-10T12:00:00Z"),
                    content: "Exact \(index)",
                    income: income,
                    outgo: .zero,
                    category: "Boundary",
                    priority: 0
                ),
                repeatID: UUID()
            )
            items.append(item)
        }
        let originalBalances = items.map(\.balance)
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try BalanceCalculator.calculate(in: context, after: .distantPast)
        }
        #expect(items.map(\.balance) == originalBalances)
    }

    @Test("A projection refuses a lost amount without changing the draft or store")
    func inexact_projection_is_refused() throws {
        let context = testContext
        let input = ItemFormInput(
            date: shiftedDate("2025-04-10T12:00:00Z"),
            content: "Exact",
            incomeText: "1" + String(repeating: "0", count: 60),
            outgoText: "1",
            category: "Boundary",
            priorityText: "0"
        )
        #expect(input.isValid)
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            _ = try ItemBalanceProjectionOperations.previewCreateComparison(
                context: context,
                input: input,
                repeatMonthSelections: []
            )
        }
        #expect(fetchItems(context).isEmpty)
        #expect(!context.hasChanges)
        #expect(input.outgoText == "1")
    }

    @Test("Yearly duplication keeps the exact amount of every duplicated item")
    func yearly_duplication_keeps_exact_amounts() throws {
        let context = testContext
        let expectedOutgo = try #require(Decimal(string: "1234.56"))
        for month in 6...8 {
            try createItem(
                context: context,
                input: .init(
                    date: shiftedDate("2024-0\(month)-10T12:00:00Z"),
                    content: "Card",
                    income: .zero,
                    outgo: expectedOutgo,
                    category: "Credit",
                    priority: 0,
                    locale: english
                )
            )
        }

        let targetItems = try duplicate(context: context)
        #expect(targetItems.count == 3)
        #expect(targetItems.allSatisfy { item in
            item.outgo == expectedOutgo
        })
    }

    @Test("A duplication average that does not divide evenly is rounded before saving")
    func duplication_average_is_rounded_before_saving() throws {
        let context = testContext
        let outgoValues = [Decimal(100), Decimal(100), Decimal(101)]
        for (month, outgo) in zip(6...8, outgoValues) {
            try createItem(
                context: context,
                input: .init(
                    date: shiftedDate("2024-0\(month)-10T12:00:00Z"),
                    content: "Card",
                    income: .zero,
                    outgo: outgo,
                    category: "Credit",
                    priority: 0,
                    locale: english
                )
            )
        }

        let targetItems = try duplicate(context: context)
        #expect(!targetItems.isEmpty)
        #expect(targetItems.allSatisfy { item in
            AmountPrecision.isExactlyStorable(item.outgo)
        })
        #expect(targetItems.allSatisfy { item in
            item.outgo == Decimal(string: "100.333333333333")
        })
    }
}

private extension ItemAmountBoundaryTests {
    func duplicate(context: ModelContext) throws -> [Item] {
        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: sourceYear,
            targetYear: targetYear
        )
        _ = try YearlyItemDuplicationApplyOperations.apply(
            plan: plan,
            context: context
        )
        let targetYearDate = try #require(
            Calendar.current.date(
                from: DateComponents(
                    year: targetYear,
                    month: firstMonthOfYear,
                    day: firstDayOfMonth
                )
            )
        )
        return try context.fetch(.items(.dateIsSameYearAs(targetYearDate)))
    }

    func seedAmounts(_ amounts: [(income: Decimal, outgo: Decimal)], at url: URL) throws {
        let container = try ModelContainerFactory.make(
            configuration: .init(url: url, cloudKitDatabase: .none)
        )
        let context = container.mainContext
        for (offset, amount) in amounts.enumerated() {
            _ = try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2025-0\(offset + 1)-10T12:00:00Z"),
                    content: "Amount \(offset)",
                    income: amount.income,
                    outgo: amount.outgo,
                    category: "Boundary",
                    priority: 0
                ),
                repeatID: UUID()
            )
        }
        try context.save()
    }

    func verifyReopenedAmounts(_ amounts: [(income: Decimal, outgo: Decimal)], at url: URL) throws {
        let container = try ModelContainerFactory.make(
            configuration: .init(url: url, cloudKitDatabase: .none)
        )
        let reopenedItems = try container.mainContext
            .fetch(FetchDescriptor<Item>())
            .sorted { left, right in
                left.content < right.content
            }

        #expect(reopenedItems.count == amounts.count)
        for (item, amount) in zip(reopenedItems, amounts) {
            #expect(item.income == amount.income)
            #expect(item.outgo == amount.outgo)
            #expect(!item.balance.isNaN)
        }
    }

    func withTemporaryStoreURL(_ body: (URL) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        try body(directory.appendingPathComponent("Incomes.sqlite"))
    }
}
