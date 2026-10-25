import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerMutationIsolationTests {
    private let largeExponent = 40
    private let secondDay = 2
    private let sourceYear = 2_025

    @Test(arguments: [false, true])
    func importingTheDefaultBookDoesNotValidateUnselectedBookBalances(replace: Bool) throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let other = try seedUnsupportedBook(context: context)
        let value = IncomesFileItem(
            date: shiftedDate("2025-01-01T00:00:00Z"),
            content: "Imported",
            income: 10,
            outgo: 0,
            category: "General",
            priority: 0,
            repeatID: UUID(),
            balance: nil
        )
        let contents = IncomesFileContents(
            formatVersion: 1,
            schemaVersion: "2.0.0",
            exportedAt: .now,
            currencyCode: nil,
            items: [value]
        )
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: replace ? .replace : .merge(.init()),
            context: context
        )
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == 10)
        #expect(try context.fetchCount(.items(.all, ledgerIdentifier: other)) == 2)
    }

    @Test
    func yearlyDuplicationDoesNotValidateAnotherBook() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        _ = try seedUnsupportedBook(context: context)
        _ = try makeItem(context: context, owner: .default, income: 10)
        try context.save()
        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_025,
            targetYear: 2_026,
            options: .init(includeSingleItems: true)
        )
        #expect(plan.entries.count == 1)
        _ = try YearlyItemDuplicationApplyOperations.apply(plan: plan, context: context)
        #expect(try context.fetchCount(.items(.all)) == 2)
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == 20)
    }

    @Test
    func metadataOnlyImportDoesNotRecalculateFinancialRecords() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let other = try seedUnsupportedBook(context: context)
        let contents = IncomesFileContents(
            formatVersion: 1,
            schemaVersion: "2.0.0",
            exportedAt: .now,
            currencyCode: nil,
            items: [],
            ledgers: [.init(id: other, name: "Renamed")],
            selectionLedgerIdentifiers: [other]
        )
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init(useFileLedgerNames: true)),
            context: context
        )
        #expect(try LedgerOperations.ledger(other, context: context).name == "Renamed")
        #expect(try context.fetchCount(.items(.all, ledgerIdentifier: other)) == 2)
    }

    @Test(arguments: [ItemMutationScope.thisItem, .futureItems, .allItems])
    func anUnsupportedUpdatedBalanceLeavesRecordsAndTagsUnchanged(scope: ItemMutationScope) throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let large = Decimal(sign: .plus, exponent: largeExponent, significand: 1)
        _ = try makeItem(context: context, owner: .default, income: large)
        let series = UUID()
        for day in 2...4 {
            _ = try makeItem(context: context, owner: .default, income: 0, day: day, repeatID: series)
        }
        try context.save()
        let target = try #require(try context.fetch(.items(.repeatIDIs(series), order: .forward)).first)
        let before = ItemExportOperations.fileItems(items: try context.fetch(.allLedgerItems()))
        let tagIDs = try Set(context.fetch(.tags(.all)).map(\.id))
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try ItemUpdateOperations.updateWithOutcome(
                context: context,
                item: target,
                input: .init(
                    date: target.localDate,
                    content: "Rejected",
                    income: 1,
                    outgo: 0,
                    category: "Rejected"
                ),
                scope: scope
            )
        }
        #expect(ItemExportOperations.fileItems(items: try context.fetch(.allLedgerItems())) == before)
        #expect(try Set(context.fetch(.tags(.all)).map(\.id)) == tagIDs)
        #expect(!context.hasChanges)
        try context.save()
        let saved = try ModelContext(context.container).fetch(.allLedgerItems())
        #expect(ItemExportOperations.fileItems(items: saved) == before)
    }

    @Test
    func updatingTiedRowsPreservesTheirSavedCalculationOrder() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        for _ in 0..<3 {
            _ = try makeItem(context: context, owner: .default, income: 0)
        }
        try context.save()
        let items = try context.fetch(.items(.all)).sorted(by: >)
        let large = Decimal(sign: .plus, exponent: largeExponent, significand: 1)
        for (item, amounts) in zip(items, [(large, Decimal.zero), (.zero, large), (1, .zero)]) {
            try item.modify(
                values: .init(
                    date: item.localDate,
                    content: item.content,
                    income: amounts.0,
                    outgo: amounts.1,
                    category: "General",
                    priority: 0
                ),
                repeatID: item.repeatID
            )
        }
        try BalanceCalculator.calculate(in: context, after: items[0].localDate)
        try context.save()
        let target = items[1]
        _ = try ItemUpdateOperations.updateWithOutcome(
            context: context,
            item: target,
            input: .init(
                date: target.localDate,
                content: target.content,
                income: target.income,
                outgo: target.outgo,
                category: "General"
            ),
            scope: .thisItem
        )
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == 1)
    }

    @Test
    func anUnsupportedBalanceAfterDeletionPreservesTheExpense() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let large = Decimal(sign: .plus, exponent: largeExponent, significand: 1)
        _ = try makeItem(context: context, owner: .default, income: large)
        let expense = try makeItem(context: context, owner: .default, income: 0, outgo: large, day: 2)
        _ = try makeItem(context: context, owner: .default, income: 1, day: 3)
        try context.save()
        let before = ItemExportOperations.fileItems(items: try context.fetch(.allLedgerItems()))
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try ItemDeletionOperations.deleteWithOutcome(context: context, item: expense)
        }
        #expect(!expense.isDeleted)
        #expect(ItemExportOperations.fileItems(items: try context.fetch(.allLedgerItems())) == before)
        #expect(!context.hasChanges)
        try context.save()
        let saved = try ModelContext(context.container).fetch(.allLedgerItems())
        #expect(ItemExportOperations.fileItems(items: saved) == before)
    }
}

private extension LedgerMutationIsolationTests {
    func seedUnsupportedBook(context: ModelContext) throws -> LedgerIdentifier {
        let other = try LedgerOperations.create(context: context, name: "Other").id
        let large = Decimal(sign: .plus, exponent: largeExponent, significand: 1)
        _ = try makeItem(context: context, owner: other, income: large)
        _ = try makeItem(context: context, owner: other, income: 1, day: secondDay)
        try context.save()
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try ItemBalanceOperations.recalculate(
                context: context, date: shiftedDate("2025-01-01T12:00:00Z"), ledgerIdentifier: other
            )
        }
        return other
    }

    func makeItem(
        context: ModelContext,
        owner: LedgerIdentifier,
        income: Decimal,
        outgo: Decimal = .zero,
        day: Int = 1,
        repeatID: UUID = UUID()
    ) throws -> Item {
        let date = try #require(Calendar.current.date(from: .init(year: sourceYear, month: 1, day: day)))
        let item = try Item.create(
            context: context,
            values: .init(
                date: date,
                content: "Saved",
                income: income,
                outgo: outgo,
                category: "General",
                priority: 0,
                ledgerIdentifier: owner
            ),
            repeatID: repeatID
        )
        item.modify(balance: income - outgo)
        return item
    }
}
