import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct ItemCreationPersistenceTests {
    private static let incomeAmount: Decimal = 200
    private static let repeatedCount = 3
    private static let selectedLaterMonth = 3
    private static let selectionYear = 2_000
    private static let selectedMonthCount = 2

    @Test
    func staging_creation_does_not_commit_the_store() throws {
        try withStore { url in
            let container = try makeContainer(at: url)
            let context = ModelContext(container)
            context.autosaveEnabled = false
            let mutation = try ItemCreationOperations.createWithOutcome(
                context: context,
                input: input,
                repeatCount: Self.repeatedCount
            )
            #expect(context.hasChanges)
            #expect(fetchItems(context).count == 3)
            #expect(!mutation.outcome.followUpHints.isEmpty)
            #expect(fetchItems(ModelContext(container)).isEmpty)
            context.rollback()
        }
    }

    @Test(arguments: [1, 3], [false, true])
    func saved_creation_reopens_with_permanent_ids_and_live_balances(
        repeatCount: Int,
        autosaveEnabled: Bool
    ) throws {
        try withStore { url in
            let createdIDs = try saveRepeatedCreation(
                at: url,
                repeatCount: repeatCount,
                autosaveEnabled: autosaveEnabled
            )
            let container = try makeContainer(at: url)
            let items = fetchItems(container.mainContext)
            let created = items.filter { item in
                item.content == input.content
            }
            #expect(created.count == repeatCount)
            #expect(Set(created.map(\.repeatID)).count == 1)
            #expect(created.allSatisfy { item in
                item.income == 200 && item.outgo == 100 && item.category?.name == "Work"
            })
            let reopenedIDs = try Set(created.map { item in
                try PersistentIdentifierCoder.encode(item.persistentModelID)
            })
            #expect(reopenedIDs == createdIDs)
            #expect(items.map(\.balance).sorted() == (1...(repeatCount + 1)).map { index in
                Decimal(index * 100)
            })
        }
    }

    @Test
    func a_reviewed_selection_is_saved_and_cannot_be_submitted_twice() throws {
        try withStore { url in
            try saveReviewedSelection(at: url)
        }
    }

    @Test
    func pending_edits_are_neither_saved_nor_rolled_back() throws {
        try withStore { url in
            try refusePendingEdits(at: url)
        }
    }

    @Test(arguments: [false, true])
    func a_real_save_failure_rolls_back_creation_and_preserves_live_balances(
        selectedMonths: Bool
    ) throws {
        try withStore { url in
            let savedItems = try seedStore(at: url)
            try attemptReadOnlyCreation(at: url, selectedMonths: selectedMonths)
            let container = try makeContainer(at: url)
            #expect(ItemExportOperations.fileItems(items: fetchItems(container.mainContext)) == savedItems)
        }
    }

    @Test(arguments: [false, true])
    func a_calculation_failure_discards_staged_items_and_tags(autosaveEnabled: Bool) throws {
        try withStore { url in
            let container = try makeContainer(at: url)
            let context = ModelContext(container)
            context.autosaveEnabled = autosaveEnabled
            let existing = try seedLaterItem(context: context)
            let savedTags = try tagIDs(context)
            let invalidBalance = ItemFormInput(
                date: input.date,
                content: "Inexact balance",
                incomeText: "1" + String(repeating: "0", count: 60),
                outgoText: "1",
                category: "Boundary",
                priorityText: "0"
            )
            #expect(invalidBalance.isValid)
            #expect(throws: ItemAmountError.balanceOutOfRange) {
                try ItemCreationOperations.createAndSaveWithOutcome(
                    context: context,
                    input: invalidBalance,
                    repeatMonthSelections: []
                )
            }
            #expect(!context.hasChanges)
            #expect(context.autosaveEnabled == autosaveEnabled)
            #expect(try tagIDs(context) == savedTags)
            #expect(fetchItems(context).count == 1)
            #expect(existing.balance == 100)
            #expect(fetchItems(ModelContext(container)).count == 1)
        }
    }
}

private extension ItemCreationPersistenceTests {
    var input: ItemFormInput {
        .init(
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "Income",
            income: Self.incomeAmount,
            outgo: 100,
            category: "Work"
        )
    }

    func saveReviewedSelection(at url: URL) throws {
        let container = try makeContainer(at: url)
        let context = ModelContext(container)
        let selections: Set<RepeatMonthSelection> = [
            .init(year: Self.selectionYear, month: 1),
            .init(year: Self.selectionYear, month: Self.selectedLaterMonth)
        ]
        let review = try ItemBalanceProjectionOperations.reviewCreate(
            context: context,
            input: input,
            repeatMonthSelections: selections
        )
        let mutation = try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: input,
            repeatMonthSelections: selections,
            review: review
        )
        #expect(mutation.outcome.changedIDs.created.count == Self.selectedMonthCount)
        #expect(!context.hasChanges)
        let savedBalance = fetchItems(context).map(\.balance).max()
        #expect(savedBalance == review.comparison.projected.monthlyBalances.last?.balance)
        let savedItems = ItemExportOperations.fileItems(items: fetchItems(ModelContext(container)))
        #expect(savedItems.count == Self.selectedMonthCount)
        #expect(throws: ItemBalanceProjectionReviewError.baselineChanged) {
            try ItemCreationOperations.createAndSaveWithOutcome(
                context: context,
                input: input,
                repeatMonthSelections: selections,
                review: review
            )
        }
        #expect(!context.hasChanges)
        #expect(ItemExportOperations.fileItems(items: fetchItems(context)) == savedItems)
    }

    func refusePendingEdits(at url: URL) throws {
        let container = try makeContainer(at: url)
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let existing = try seedLaterItem(context: context)
        try existing.modify(
            values: .init(
                date: existing.localDate,
                content: "Unsaved draft",
                income: existing.income,
                outgo: existing.outgo,
                category: "Unsaved category",
                priority: existing.priority
            ),
            repeatID: existing.repeatID
        )
        let pendingTags = try tagIDs(context)
        #expect(throws: ItemCreationError.pendingChanges) {
            try ItemCreationOperations.createAndSaveWithOutcome(
                context: context,
                input: input,
                repeatCount: Self.repeatedCount
            )
        }
        #expect(context.hasChanges)
        #expect(!context.autosaveEnabled)
        #expect(existing.content == "Unsaved draft")
        #expect(existing.category?.name == "Unsaved category")
        #expect(try tagIDs(context) == pendingTags)
        let stored = try #require(fetchItems(ModelContext(container)).first)
        #expect(stored.content == "Later")
        #expect(stored.category?.name == "Work")
        #expect(fetchItems(context).count == 1)
        context.rollback()
    }

    func makeContainer(at url: URL) throws -> ModelContainer {
        try ModelContainerFactory.make(
            configuration: .init(url: url, cloudKitDatabase: .none)
        )
    }

    func seedLaterItem(context: ModelContext) throws -> Item {
        let item = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-04-01T12:00:00Z"),
                content: "Later",
                income: 100,
                outgo: 0,
                category: "Work"
            )
        )
        try context.save()
        return item
    }

    func seedStore(at url: URL) throws -> [IncomesFileItem] {
        let container = try makeContainer(at: url)
        _ = try seedLaterItem(context: container.mainContext)
        return ItemExportOperations.fileItems(items: fetchItems(container.mainContext))
    }

    func saveRepeatedCreation(
        at url: URL,
        repeatCount: Int,
        autosaveEnabled: Bool
    ) throws -> Set<String> {
        let container = try makeContainer(at: url)
        let context = ModelContext(container)
        context.autosaveEnabled = autosaveEnabled
        let existing = try seedLaterItem(context: context)
        let mutation = try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: input,
            repeatCount: repeatCount
        )
        #expect(!context.hasChanges)
        #expect(context.autosaveEnabled == autosaveEnabled)
        #expect(existing.balance == Decimal((repeatCount + 1) * 100))
        let fetched = try #require(try ItemQueryOperations.item(
            context: context,
            persistentID: mutation.value.persistentModelID
        ))
        #expect(fetched === mutation.value)
        let stillLive = try #require(try ItemQueryOperations.item(
            context: context,
            persistentID: existing.persistentModelID
        ))
        #expect(stillLive === existing)
        #expect(mutation.outcome.changedIDs.created.count == repeatCount)
        #expect(mutation.outcome.followUpHints == ItemMutationSupport.followUpHints)
        #expect(mutation.outcome.affectedDateRange != nil)
        return try withExtendedLifetime(container) {
            try Set(mutation.outcome.changedIDs.created.map(PersistentIdentifierCoder.encode))
        }
    }

    func attemptReadOnlyCreation(at url: URL, selectedMonths: Bool) throws {
        let container = try ModelContainerFactory.readOnly(at: url)
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let existing = try #require(fetchItems(context).first)
        let savedTags = try tagIDs(context)
        let selections: Set<RepeatMonthSelection> = [.init(year: Self.selectionYear, month: Self.selectedLaterMonth)]
        #expect(throws: (any Error).self) {
            if selectedMonths {
                return try ItemCreationOperations.createAndSaveWithOutcome(
                    context: context,
                    input: input,
                    repeatMonthSelections: selections
                )
            }
            return try ItemCreationOperations.createAndSaveWithOutcome(
                context: context,
                input: input,
                repeatCount: Self.repeatedCount
            )
        }
        #expect(!context.hasChanges)
        #expect(!context.autosaveEnabled)
        #expect(existing.balance == 100)
        #expect(existing.content == "Later")
        #expect(fetchItems(context).count == 1)
        #expect(try tagIDs(context) == savedTags)
    }

    func tagIDs(_ context: ModelContext) throws -> Set<PersistentIdentifier> {
        try Set(context.fetch(.tags(.all)).map(\.persistentModelID))
    }

    func withStore(_ body: (URL) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        try autoreleasepool {
            try body(directory.appendingPathComponent("Incomes.sqlite"))
        }
    }
}
