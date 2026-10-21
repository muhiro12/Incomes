import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemImportBalanceTests {
    @Test(arguments: [ItemImportBalancePolicy.preserveSavedBalances, .recalculate])
    func a_balance_difference_is_a_choice_and_the_review_does_not_write(
        _ balancePolicy: ItemImportBalancePolicy
    ) throws {
        let context = testContext
        let contents = contents([fileItem(day: 8, income: 100, balance: 1)])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        let review = try ItemImportOperations.balanceReview(difference: difference, policy: .replace)
        #expect(review.hasDifferences)
        #expect(review.canRecalculate)
        #expect(fetchItems(context).isEmpty)
        #expect(!context.hasChanges)
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: context,
            balancePolicy: balancePolicy
        )
        #expect(fetchItems(context).map(\.balance) == [balancePolicy == .recalculate ? 100 : 1])
    }

    @Test(arguments: [ItemImportBalancePolicy.preserveSavedBalances, .recalculate])
    func either_choice_starts_from_the_preceding_saved_baseline(
        _ balancePolicy: ItemImportBalancePolicy
    ) throws {
        let context = testContext
        let predecessor = try createItem(context: context, day: 8, income: 100, balance: 1)
        try createItem(context: context, day: 10, income: -2, balance: 999)
        let contents = contents([fileItem(day: 9, income: 50, balance: 7)])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init()),
            context: context,
            balancePolicy: balancePolicy
        )
        #expect(predecessor.balance == 1)
        #expect(fetchItems(context).sorted(by: >).map(\.balance)
                    == (balancePolicy == .recalculate ? [1, 51, 49] : [1, 7, 5]))
    }

    @Test
    func a_missing_file_balance_continues_from_the_restored_baseline() throws {
        let context = testContext
        let contents = contents([
            fileItem(day: 8, income: 100, balance: 1),
            fileItem(day: 9, income: 20)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init()),
            context: context
        )
        #expect(fetchItems(context).sorted(by: >).map(\.balance) == [1, 21])
    }

    @Test
    func matching_balances_need_no_choice_and_excluded_items_do_not_raise_a_warning() throws {
        let context = testContext
        let contents = contents([
            fileItem(day: 8, income: 100, balance: 100),
            fileItem(day: 9, income: 20, balance: 1)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        var decisions = ItemImportMergeDecisions()
        decisions.excludedAdditionIndices.insert(1)
        let review = try ItemImportOperations.balanceReview(difference: difference, policy: .merge(decisions))
        #expect(!review.hasDifferences)
        #expect(review.canRecalculate)
    }

    @Test
    func a_saved_balance_change_invalidates_the_review() throws {
        let context = testContext
        let predecessor = try createItem(context: context, day: 8, income: 100, balance: 1)
        let contents = contents([fileItem(day: 9, income: 20)])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        predecessor.modify(balance: 2)
        #expect(throws: ItemImportError.storeChangedSinceReview) {
            try ItemImportOperations.applyWithOutcome(
                contents: contents,
                reviewed: difference,
                policy: .merge(.init()),
                context: context
            )
        }
        #expect(fetchItems(context).count == 1)
        #expect(predecessor.balance == 2)
    }

    @Test
    func valid_saved_balances_can_be_restored_when_recalculation_overflows() throws {
        let context = testContext
        let contents = contents([
            fileItem(day: 8, income: 999_999_999_999_999, balance: 1),
            fileItem(day: 9, income: 999_999_999_999_999, balance: 2)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        let review = try ItemImportOperations.balanceReview(difference: difference, policy: .replace)
        #expect(review.hasDifferences)
        #expect(!review.canRecalculate)
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try ItemImportOperations.applyWithOutcome(
                contents: contents,
                reviewed: difference,
                policy: .replace,
                context: context,
                balancePolicy: .recalculate
            )
        }
        #expect(fetchItems(context).isEmpty)
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: context
        )
        #expect(fetchItems(context).sorted(by: >).map(\.balance) == [1, 2])
    }

    @Test
    func saved_balances_stay_with_their_records_when_sort_keys_tie() throws {
        let context = testContext
        let contents = contents([
            fileItem(day: 8, income: 10, balance: 17),
            fileItem(day: 8, income: 20, balance: 23)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: context
        )
        let restored = fetchItems(context)
        for fileItem in contents.items {
            let item = try #require(restored.first { $0.repeatID == fileItem.repeatID })
            #expect(item.balance == fileItem.balance)
            #expect(item.priority == fileItem.priority)
        }
    }

    @Test(arguments: [ItemImportBalancePolicy.preserveSavedBalances, .recalculate])
    func a_new_ledger_uses_its_destination_identity_and_leaves_other_ledgers_unchanged(
        _ balancePolicy: ItemImportBalancePolicy
    ) throws {
        let context = testContext
        let existing = try createItem(context: context, day: 8, income: 100, balance: 17)
        try context.save()
        let reference = LedgerIdentifier(rawValue: "file-ledger")
        let contents = IncomesFileContents(
            schemaVersion: "3.0.0",
            exportedAt: isoDate("2026-10-21T00:00:00Z"),
            currencyCode: "JPY",
            items: [fileItem(day: 9, income: 20, balance: 1).assigning(to: reference)],
            ledgers: [.init(id: reference, name: "Restored")],
            selectionLedgerIdentifiers: [reference]
        )
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: context,
            balancePolicy: balancePolicy
        )
        let reader = ModelContext(context.container)
        let allItems = try reader.fetch(FetchDescriptor<Item>.allLedgerItems())
        let restored = try #require(allItems.first { $0.ledgerIdentifier != .default })
        #expect(restored.ledgerIdentifier != reference)
        #expect(restored.balance == (balancePolicy == .recalculate ? 20 : 1))
        #expect(allItems.first { $0.persistentModelID == existing.persistentModelID }?.balance == 17)
    }
}

// swiftlint:disable no_magic_numbers
private extension ItemImportBalanceTests {
    func fileItem(day: Int, income: Decimal, balance: Decimal? = nil) -> IncomesFileItem {
        .init(
            date: isoDate("2026-03-\(day < 10 ? "0" : "")\(day)T00:00:00Z"),
            content: "Item",
            income: income,
            outgo: .zero,
            category: "",
            priority: 0,
            repeatID: UUID(),
            balance: balance
        )
    }

    func contents(_ items: [IncomesFileItem]) -> IncomesFileContents {
        .init(
            schemaVersion: "3.0.0",
            exportedAt: isoDate("2026-10-21T00:00:00Z"),
            currencyCode: "JPY",
            items: IncomesFileItem.sortedByValue(items)
        )
    }

    @discardableResult
    func createItem(context: ModelContext, day: Int, income: Decimal, balance: Decimal) throws -> Item {
        let file = fileItem(day: day, income: income, balance: balance)
        let item = try Item.create(context: context, values: file.storedValues, repeatID: file.repeatID)
        item.modify(balance: balance)
        return item
    }
}

// swiftlint:enable no_magic_numbers
