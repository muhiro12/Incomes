import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct ItemExportPriorityTests {
    @Test(arguments: [Decimal(150), 7])
    func a_tied_ending_balance_survives_restore_without_changing_the_source(endingBalance: Decimal) throws {
        let context = try makeContext()
        let items = try seed(context: context, priorities: [0, 0])
        for (index, item) in items.enumerated() {
            try item.modify(
                values: .init(
                    date: item.localDate,
                    content: item.content,
                    income: index == 0 ? 100 : 50,
                    outgo: 0,
                    category: "",
                    priority: 0
                ),
                repeatID: item.repeatID
            )
            item.modify(balance: index == 0 ? 100 : endingBalance)
        }
        try context.save()
        let preparation = ItemExportOperations.prepareFile(items: items.reversed())
        #expect(preparation.adjustedPriorityCount == 1)
        #expect(preparation.unresolvedDayCount == 0)
        #expect(items.map(\.priority) == [0, 0])
        #expect(items.map(\.balance) == [100, endingBalance])
        #expect(!context.hasChanges)

        let contents = try decoded(preparation)
        let destination = try makeContext()
        let review = try ItemImportOperations.difference(contents: contents, context: destination)
        #expect(try !ItemImportOperations.balanceReview(difference: review, policy: .replace).hasAmbiguousOrder)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents, reviewed: review, policy: .replace, context: destination
        )
        let reader = ModelContext(destination.container)
        #expect(try LedgerBalanceOperations.snapshot(context: reader).latestBalance == endingBalance)
        #expect(try ItemImportOperations.difference(contents: contents, context: reader).isIdentical)
        #expect(try ItemExportOperations.fileItems(items: reader.fetch(.allLedgerItems())) == preparation.items)
    }

    @Test
    func reimport_shows_priority_changes_without_adding_duplicates_or_rebuilding_matched_balances() throws {
        let context = try makeContext()
        let items = try seed(context: context, priorities: [0, 0])
        let repeatIDs = [
            try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000001")),
            try #require(UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"))
        ]
        for (item, repeatID) in zip(items, repeatIDs) {
            try item.modify(
                values: .init(
                    date: item.localDate,
                    content: item.content,
                    income: 1,
                    outgo: 0,
                    category: "",
                    priority: 0
                ),
                repeatID: repeatID
            )
        }
        items[0].modify(balance: 1)
        items[1].modify(balance: 7)
        try context.save()
        let contents = try decoded(ItemExportOperations.prepareFile(items: items))
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(!difference.changeGroups.isEmpty)
        #expect(difference.matchedCount == 1)
        #expect(difference.changeGroups.flatMap(\.fileItems).map(\.priority) == [1])
        #expect(difference.changeGroups.flatMap(\.storeItems).map(\.item.priority) == [0])
        #expect(difference.changeGroups.flatMap(\.storeItems).map(\.item.balance) == [1])
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents, reviewed: difference, policy: .merge(.init()), context: context
        )
        #expect(try context.fetchCount(.allLedgerItems()) == 2)
        #expect(items.map(\.priority) == [0, 0])
        let replacement = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents, reviewed: replacement, policy: .replace, context: context
        )
        let reader = ModelContext(context.container)
        #expect(try LedgerBalanceOperations.snapshot(context: reader).latestBalance == 7)
        #expect(try reader.fetchCount(.allLedgerItems()) == 2)
    }

    @Test(arguments: [2, 11, 12])
    func priority_capacity_is_bounded_and_never_partially_adjusts_a_saturated_day(count: Int) throws {
        let context = try makeContext()
        let items = try seed(context: context, priorities: Array(repeating: 0, count: count))
        let preparation = ItemExportOperations.prepareFile(items: items)
        if count <= ItemFormInput.priorityRange.count {
            #expect(preparation.unresolvedDayCount == 0)
            #expect(preparation.adjustedPriorityCount == count - 1)
            #expect(Set(preparation.items.map(\.priority)).count == count)
            #expect(preparation.items.map(\.repeatID) == items.map(\.repeatID))
        } else {
            #expect(preparation.unresolvedDayCount == 1)
            #expect(preparation.adjustedPriorityCount == 0)
            #expect(preparation.items.allSatisfy { $0.priority == 0 })
            let destination = try makeContext()
            let difference = try ItemImportOperations.difference(contents: decoded(preparation), context: destination)
            #expect(try ItemImportOperations.balanceReview(difference: difference, policy: .replace).hasAmbiguousOrder)
        }
        #expect(preparation.items.allSatisfy { ItemFormInput.priorityRange.contains($0.priority) })
        #expect(items.allSatisfy { $0.priority == 0 })
        #expect(!context.hasChanges)
    }

    @Test
    func existing_priorities_are_reused_and_neighbouring_items_keep_their_order() throws {
        let context = try makeContext()
        let items = try seed(context: context, priorities: [1, 0, 0])
        let preparation = ItemExportOperations.prepareFile(items: items)
        #expect(preparation.items.map(\.priority) == [2, 1, 0])
        #expect(preparation.items.map(\.repeatID) == items.map(\.repeatID))
        #expect(items.map(\.priority) == [1, 0, 0])
        #expect(!context.hasChanges)
    }

    @Test
    func a_day_with_every_priority_in_use_reports_capacity_without_adjustment() throws {
        let context = try makeContext()
        let items = try seed(context: context, priorities: Array(ItemFormInput.priorityRange) + [0])
        let preparation = ItemExportOperations.prepareFile(items: items)
        #expect(preparation.unresolvedDayCount == 1)
        #expect(preparation.adjustedPriorityCount == 0)
        #expect(preparation.items.map(\.priority).sorted() == items.map(\.priority).sorted())
        #expect(!context.hasChanges)
    }

    @Test
    func a_full_priority_range_can_be_reused_when_descriptions_leave_room() throws {
        let context = try makeContext()
        let priorities = Array(ItemFormInput.priorityRange.reversed()) + [0]
        let descriptions = (0..<11).map { String(format: "Item %02d", $0) } + ["Item 10"]
        let items = try seed(context: context, priorities: priorities, descriptions: descriptions)
        let originalPriorities = items.map(\.priority)
        let preparation = ItemExportOperations.prepareFile(items: items)
        #expect(Set(originalPriorities) == Set(ItemFormInput.priorityRange))
        #expect(preparation.adjustedPriorityCount == 1)
        #expect(preparation.unresolvedDayCount == 0)
        #expect(preparation.items.map(\.repeatID) == items.map(\.repeatID))
        #expect(preparation.items.allSatisfy { ItemFormInput.priorityRange.contains($0.priority) })
        #expect(items.map(\.priority) == originalPriorities)
        #expect(!context.hasChanges)

        let destination = try makeContext()
        let contents = try decoded(preparation)
        let difference = try ItemImportOperations.difference(contents: contents, context: destination)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents, reviewed: difference, policy: .replace, context: destination
        )
        let reader = ModelContext(destination.container)
        let restored = try reader.fetch(FetchDescriptor<Item>.allLedgerItems()).sorted(by: >)
        #expect(restored.map(\.repeatID) == items.map(\.repeatID))
        #expect(restored.map(\.balance) == items.map(\.balance))
    }

    @Test
    func more_than_eleven_items_can_share_priorities_when_descriptions_resolve_their_order() throws {
        let context = try makeContext()
        let descriptions = (0..<20).map { String(format: "Item %02d", $0) } + ["Item 10"]
        let items = try seed(
            context: context,
            priorities: Array(repeating: 0, count: descriptions.count),
            descriptions: descriptions
        )
        let preparation = ItemExportOperations.prepareFile(items: items)
        #expect(preparation.unresolvedDayCount == 0)
        #expect(preparation.adjustedPriorityCount > 0)
        #expect(preparation.items.map(\.repeatID) == items.map(\.repeatID))
        #expect(preparation.items.allSatisfy { ItemFormInput.priorityRange.contains($0.priority) })
    }

    @Test
    func unambiguous_priorities_stay_unchanged() throws {
        let context = try makeContext()
        let items = try seed(context: context, priorities: [10, 5, 0])
        let preparation = ItemExportOperations.prepareFile(items: items)
        #expect(preparation.adjustedPriorityCount == 0)
        #expect(preparation.unresolvedDayCount == 0)
        #expect(preparation.items.map(\.priority) == items.map(\.priority))
    }

    @Test
    func priority_adjustment_stays_inside_the_affected_ledger_day() throws {
        let context = try makeContext()
        _ = try seed(context: context, priorities: [0, 0])
        let ledger = try LedgerOperations.create(context: context, name: "Other")
        let otherDay = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2026-03-09T00:00:00Z"),
                content: "Same",
                income: 1,
                outgo: 0,
                category: "",
                priority: 3
            ),
            repeatID: UUID()
        )
        let otherLedger = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2026-03-08T00:00:00Z"),
                content: "Same",
                income: 1,
                outgo: 0,
                category: "",
                priority: 3,
                ledgerIdentifier: ledger.id
            ),
            repeatID: UUID()
        )
        try context.save()
        let preparation = try ItemExportOperations.prepareFile(items: context.fetch(.allLedgerItems()))
        #expect(preparation.adjustedPriorityCount == 1)
        #expect(preparation.unresolvedDayCount == 0)
        for item in [otherDay, otherLedger] {
            #expect(preparation.items.first { $0.repeatID == item.repeatID }?.priority == 3)
        }
        #expect(!context.hasChanges)
    }
}

private extension ItemExportPriorityTests {
    func makeContext() throws -> ModelContext {
        ModelContext(try ModelContainerFactory.inMemory())
    }

    func seed(context: ModelContext, priorities: [Int], descriptions: [String] = []) throws -> [Item] {
        for (index, priority) in priorities.enumerated() {
            _ = try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2026-03-08T00:00:00Z"),
                    content: descriptions.isEmpty ? "Same" : descriptions[index],
                    income: 1,
                    outgo: 0,
                    category: "",
                    priority: priority
                ),
                repeatID: UUID()
            )
        }
        try context.save()
        let items = try context.fetch(FetchDescriptor<Item>.allLedgerItems()).sorted(by: >)
        for (index, item) in items.enumerated() {
            item.modify(balance: Decimal(index + 1))
        }
        try context.save()
        return items
    }

    func decoded(_ preparation: ItemExportPreparation) throws -> IncomesFileContents {
        try ItemImportOperations.read(data: ItemExportOperations.incomesFileData(
            fileItems: preparation.items, currencyCode: "JPY"
        ))
    }
}
