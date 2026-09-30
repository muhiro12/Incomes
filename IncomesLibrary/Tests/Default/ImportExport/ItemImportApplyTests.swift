import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemImportApplyTests {
    @Test
    func empty_store_receives_every_item_with_recalculated_balances() throws {
        let context = testContext
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Salary", income: 300_000, balance: 1),
            fileItem(day: "2026-03-09", content: "Rent", outgo: 80_000, category: "Housing", balance: 2)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        let result = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init()),
            context: context
        )
        #expect(result.value == .init(addedCount: 2, removedCount: 0, unchangedCount: 0))
        #expect(result.outcome.changedIDs.created.count == 2)
        #expect(result.outcome.followUpHints == ItemMutationSupport.followUpHints)
        let items = fetchItems(context).sorted(by: >)
        #expect(items.map(\.content) == ["Salary", "Rent"])
        #expect(items.map(\.balance) == [300_000, 220_000])
        #expect(items.last?.category?.name == "Housing")
        #expect(try ItemImportOperations.difference(contents: contents, context: context).isIdentical)
    }

    @Test
    func replace_makes_the_store_equal_to_the_file_and_keeps_matched_items() throws {
        let context = testContext
        let matched = try createItem(context: context, day: "2026-03-08", content: "Rent", outgo: 80_000)
        let matchedID = matched.persistentModelID
        try createItem(context: context, day: "2026-03-09", content: "Gym", outgo: 7_000, category: "Health")
        try createItem(context: context, day: "2026-03-10", content: "Coffee", outgo: 500)
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Rent", outgo: 80_000),
            fileItem(day: "2026-03-10", content: "Coffee", outgo: 650),
            fileItem(day: "2026-03-11", content: "Book", outgo: 2_000)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(ItemImportOperations.result(difference: difference, policy: .replace)
                    == .init(addedCount: 2, removedCount: 2, unchangedCount: 1))
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: context
        )
        let items = fetchItems(context).sorted(by: >)
        #expect(items.map(\.content) == ["Rent", "Coffee", "Book"])
        #expect(items.map(\.outgo) == [80_000, 650, 2_000])
        #expect(items.first?.persistentModelID == matchedID)
        #expect(items.map(\.balance) == [-80_000, -80_650, -82_650])
        #expect(try ItemImportOperations.difference(contents: contents, context: context).isIdentical)
        let tagNames = try context.fetch(FetchDescriptor<IncomesLibrary.Tag>()).map(\.name)
        #expect(!tagNames.contains("Gym"))
        #expect(!tagNames.contains("Health"))
    }

    @Test(arguments: [
        (ItemImportMergeDecisions.Resolution.keepCurrent, [500], ["Book"]),
        (.useFile, [650], ["Book"]),
        (.keepBoth, [500, 650], ["Book"])
    ])
    func merge_applies_each_group_resolution_and_keeps_store_only_items(
        resolution: ItemImportMergeDecisions.Resolution,
        coffeeOutgoes: [Decimal],
        additions: [String]
    ) throws {
        let context = testContext
        try createItem(context: context, day: "2026-03-08", content: "Rent", outgo: 80_000)
        try createItem(context: context, day: "2026-03-09", content: "Gym", outgo: 7_000)
        try createItem(context: context, day: "2026-03-10", content: "Coffee", outgo: 500)
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Rent", outgo: 80_000),
            fileItem(day: "2026-03-10", content: "Coffee", outgo: 650),
            fileItem(day: "2026-03-11", content: "Book", outgo: 2_000)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        let group = try #require(difference.changeGroups.first)
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init(resolutions: [group.id: resolution])),
            context: context
        )
        let items = fetchItems(context)
        let coffees = items.filter { item in
            item.content == "Coffee"
        }
        #expect(coffees.map(\.outgo).sorted() == coffeeOutgoes)
        #expect(items.contains { item in
            item.content == "Gym"
        })
        #expect(items.filter { item in
            additions.contains(item.content)
        }.count == additions.count)
    }

    @Test
    func merge_skips_excluded_additions() throws {
        let context = testContext
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Book", outgo: 2_000),
            fileItem(day: "2026-03-09", content: "Coffee", outgo: 500)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        let excludedIndex = try #require(difference.additions.firstIndex { item in
            item.content == "Book"
        })
        let result = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init(excludedAdditionIndices: [excludedIndex])),
            context: context
        )
        #expect(result.value.addedCount == 1)
        #expect(fetchItems(context).map(\.content) == ["Coffee"])
    }

    @Test
    func a_store_change_after_review_refuses_the_import_without_changes() throws {
        let context = testContext
        try createItem(context: context, day: "2026-03-08", content: "Rent", outgo: 80_000)
        let contents = makeContents([
            fileItem(day: "2026-03-09", content: "Book", outgo: 2_000)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        try createItem(context: context, day: "2026-03-10", content: "Synced", outgo: 100)
        #expect(throws: ItemImportError.storeChangedSinceReview) {
            try ItemImportOperations.applyWithOutcome(
                contents: contents,
                reviewed: difference,
                policy: .replace,
                context: context
            )
        }
        #expect(fetchItems(context).map(\.content).sorted() == ["Rent", "Synced"])
    }

    @Test
    func an_unstorable_balance_refuses_the_import_before_inserting() throws {
        let context = testContext
        try createItem(context: context, day: "2026-03-08", content: "Savings", income: 999_999_999_999_999)
        let contents = makeContents([
            fileItem(day: "2026-03-09", content: "Bonus", income: 999_999_999_999_999)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try ItemImportOperations.applyWithOutcome(
                contents: contents,
                reviewed: difference,
                policy: .merge(.init()),
                context: context
            )
        }
        #expect(fetchItems(context).map(\.content) == ["Savings"])
    }

    @Test
    func a_matched_items_recurrence_change_invalidates_the_review() throws {
        let context = testContext
        let item = try createItem(context: context, day: "2026-03-08", content: "Rent", outgo: 80_000)
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Rent", outgo: 80_000),
            fileItem(day: "2026-03-09", content: "Book", outgo: 2_000)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(difference.matchedCount == 1)
        try item.modify(values: IncomesFileItem(item: item).storedValues, repeatID: UUID())
        #expect(throws: ItemImportError.storeChangedSinceReview) {
            try ItemImportOperations.applyWithOutcome(
                contents: contents,
                reviewed: difference,
                policy: .replace,
                context: context
            )
        }
        #expect(fetchItems(context).map(\.content) == ["Rent"])
    }

    @Test
    func replace_validates_balances_without_the_items_it_removes() throws {
        let context = testContext
        try createItem(context: context, day: "2026-03-08", content: "Savings", income: 999_999_999_999_999)
        let contents = makeContents([
            fileItem(day: "2026-03-09", content: "Bonus", income: 999_999_999_999_999)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: context
        )
        #expect(fetchItems(context).map(\.content) == ["Bonus"])
    }

    @Test
    func identical_file_changes_nothing() throws {
        let context = testContext
        try createItem(context: context, day: "2026-03-08", content: "Rent", outgo: 80_000)
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Rent", outgo: 80_000)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        let result = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: context
        )
        #expect(result.value == .init(addedCount: 0, removedCount: 0, unchangedCount: 1))
        #expect(result.outcome.followUpHints.isEmpty)
    }

    @Test
    func import_recalculates_matched_predecessors_before_new_items() throws {
        let context = testContext
        let salary = try createItem(context: context, day: "2026-03-08", content: "Salary", income: 100)
        salary.modify(balance: 1)
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Salary", income: 100),
            fileItem(day: "2026-03-09", content: "Book", outgo: 10)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init()),
            context: context
        )
        #expect(fetchItems(context).sorted(by: >).map(\.balance) == [100, 90])
    }
}

private extension ItemImportApplyTests {
    func fileItem(
        day: String,
        content: String,
        income: Decimal = .zero,
        outgo: Decimal = .zero,
        category: String = "Category",
        balance: Decimal? = nil
    ) -> IncomesFileItem {
        .init(
            date: isoDate("\(day)T00:00:00Z"),
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: 0,
            repeatID: UUID(),
            balance: balance
        )
    }

    func makeContents(_ items: [IncomesFileItem]) -> IncomesFileContents {
        .init(
            schemaVersion: "2.0.0",
            exportedAt: isoDate("2026-09-29T00:00:00Z"),
            currencyCode: "JPY",
            items: IncomesFileItem.sortedByValue(items)
        )
    }

    @discardableResult
    func createItem(
        context: ModelContext,
        day: String,
        content: String,
        income: Decimal = .zero,
        outgo: Decimal = .zero,
        category: String = "Category"
    ) throws -> Item {
        let item = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("\(day)T00:00:00Z"),
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                priority: 0
            ),
            repeatID: UUID()
        )
        try BalanceCalculator.calculate(in: context, for: [item])
        return item
    }
}
