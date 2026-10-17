import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct ItemMutationPersistenceTests {
    private static let originalIncome: Decimal = 100
    private static let standardIncome: Decimal = 90
    private static let changedIncome: Decimal = 125
    private static let repeatCount = 3

    @Test(arguments: [ItemMutationScope.thisItem, .futureItems, .allItems], [false, true])
    func saved_updates_reopen_with_scoped_amounts_tags_and_balances(
        scope: ItemMutationScope,
        autosaveEnabled: Bool
    ) throws {
        try withStore { url in
            let owner = try saveUpdate(at: url, scope: scope, autosaveEnabled: autosaveEnabled)
            let reader = ModelContext(try container(at: url))
            let items = try reader.fetch(.items(.all, order: .forward, ledgerIdentifier: owner))
            let changedCount = scope == .thisItem ? 1 : scope == .futureItems ? 2 : 3
            #expect(
                items.filter { $0.content == "Changed" && $0.category?.name == "New" }.count == changedCount
            )
            #expect(items.reduce(Decimal.zero) { $0 + $1.income } == Decimal(300 + 25 * changedCount))
            try verifyBalances(reader, owner: owner, expected: Decimal(300 + 25 * changedCount))
            try verifyBalances(reader, owner: .default, expected: 90)
        }
    }

    @Test(arguments: [false, true])
    func saved_deletions_reopen_with_an_empty_book_and_other_book_intact(autosaveEnabled: Bool) throws {
        try withStore { url in
            let owner = try saveDeletion(at: url, autosaveEnabled: autosaveEnabled)
            let reader = ModelContext(try container(at: url))
            #expect(try reader.fetchCount(.items(.all, ledgerIdentifier: owner)) == 0)
            #expect(try LedgerOperations.account(owner, context: reader).name == "Additional")
            try verifyBalances(reader, owner: .default, expected: 90)
        }
    }

    @Test
    func reviewed_update_is_committed_and_a_stale_review_is_refused() throws {
        try withStore { url in
            let context = ModelContext(try container(at: url))
            let fixture = try seed(context)
            let input = changedInput(for: fixture.items[1])
            let review = try ItemBalanceProjectionOperations.reviewUpdate(
                context: context,
                item: fixture.items[1],
                input: input,
                scope: .futureItems
            )
            let outcome = try ItemUpdateOperations.updateAndSaveWithOutcome(
                context: context,
                item: fixture.items[1],
                input: input,
                review: review
            )
            #expect(outcome.changedIDs.updated.count == 2)
            #expect(!context.hasChanges)
            #expect(throws: ItemBalanceProjectionReviewError.baselineChanged) {
                try ItemUpdateOperations.updateAndSaveWithOutcome(
                    context: context,
                    item: fixture.items[1],
                    input: input,
                    review: review
                )
            }
            try verifyBalances(ModelContext(try container(at: url)), owner: fixture.owner, expected: 350)
        }
    }

    @Test(arguments: [false, true])
    func pending_changes_are_neither_committed_nor_rolled_back(deleting: Bool) throws {
        try withStore { url in
            let context = ModelContext(try container(at: url))
            context.autosaveEnabled = false
            let fixture = try seed(context)
            let draft = try #require(try context.fetch(.items(.all)).first)
            try draft.modify(values: .init(formInput: changedInput(for: draft)), repeatID: draft.repeatID)
            #expect(throws: ItemMutationError.pendingChanges) {
                try mutateAndSave(context, items: fixture.items, deleting: deleting)
            }
            #expect(context.hasChanges)
            #expect(draft.content == "Changed")
            #expect(try context.fetchCount(.items(.all, ledgerIdentifier: fixture.owner)) == 3)
            try verifyBalances(ModelContext(try container(at: url)), owner: .default, expected: 90)
            context.rollback()
        }
    }

    @Test(arguments: [false, true])
    func read_only_store_refuses_mutations_without_changing_live_records(deleting: Bool) throws {
        try withStore { url in
            let owner: LedgerIdentifier = try autoreleasepool {
                try seed(ModelContext(try container(at: url))).owner
            }
            let context = ModelContext(try ModelContainerFactory.readOnly(at: url))
            let items = try context.fetch(.items(.all, order: .forward, ledgerIdentifier: owner))
            let before = try archive(context)
            #expect(throws: CocoaError(.fileWriteNoPermission)) {
                try mutateAndSave(context, items: items, deleting: deleting)
            }
            #expect(!context.hasChanges)
            #expect(try archive(context) == before)
            #expect(items[0].content == "Original")
            #expect(try archive(ModelContext(try container(at: url))) == before)
        }
    }

    @Test(arguments: [false, true], [false, true])
    func failure_after_staging_restores_existing_records_and_tag_relationships(
        deleting: Bool,
        autosaveEnabled: Bool
    ) throws {
        try withStore { url in
            let context = ModelContext(try container(at: url))
            let fixture = try seed(context)
            let before = try archive(context)
            let beforeTags = try Set(context.fetch(.tags(.all)).map(\.persistentModelID))
            context.autosaveEnabled = autosaveEnabled
            #expect(throws: CocoaError(.fileWriteUnknown)) {
                try ItemMutationSupport.performAndSave(context: context) {
                    if deleting {
                        _ = try ItemDeletionOperations.deleteWithOutcome(context: context, items: fixture.items)
                    } else {
                        _ = try ItemUpdateOperations.updateWithOutcome(
                            context: context,
                            item: fixture.items[1],
                            input: changedInput(for: fixture.items[1]),
                            scope: .allItems
                        )
                    }
                    throw CocoaError(.fileWriteUnknown)
                }
            }
            #expect(!context.hasChanges)
            #expect(context.autosaveEnabled == autosaveEnabled)
            #expect(try archive(context) == before)
            #expect(try Set(context.fetch(.tags(.all)).map(\.persistentModelID)) == beforeTags)
            #expect(fixture.items[0].content == "Original")
            #expect(fixture.items[0].ledgerIdentifier == fixture.owner)
            #expect(try archive(ModelContext(try container(at: url))) == before)
        }
    }
}

private extension ItemMutationPersistenceTests {
    func saveUpdate(
        at url: URL,
        scope: ItemMutationScope,
        autosaveEnabled: Bool
    ) throws -> LedgerIdentifier {
        let context = ModelContext(try container(at: url))
        let fixture = try seed(context)
        context.autosaveEnabled = autosaveEnabled
        let target = fixture.items[1]
        let outcome = try ItemUpdateOperations.updateAndSaveWithOutcome(
            context: context,
            item: target,
            input: changedInput(for: target),
            scope: scope
        )
        #expect(outcome.changedIDs.updated.contains(target.id))
        #expect(outcome.followUpHints == ItemMutationSupport.followUpHints)
        #expect(!context.hasChanges)
        #expect(context.autosaveEnabled == autosaveEnabled)
        #expect(try ItemQueryOperations.item(context: context, persistentID: target.id) === target)
        return fixture.owner
    }

    func saveDeletion(at url: URL, autosaveEnabled: Bool) throws -> LedgerIdentifier {
        let context = ModelContext(try container(at: url))
        let fixture = try seed(context)
        context.autosaveEnabled = autosaveEnabled
        let deletedIDs = Set(fixture.items.map(\.persistentModelID))
        let outcome = try ItemDeletionOperations.deleteAndSaveWithOutcome(
            context: context,
            items: fixture.items
        )
        #expect(outcome.changedIDs.deleted == deletedIDs)
        #expect(outcome.followUpHints == ItemMutationSupport.followUpHints)
        #expect(!context.hasChanges)
        #expect(context.autosaveEnabled == autosaveEnabled)
        return fixture.owner
    }

    func seed(_ context: ModelContext) throws -> (owner: LedgerIdentifier, items: [Item]) {
        let owner = try LedgerOperations.create(context: context, name: "Additional").id
        _ = try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Original",
                income: Self.originalIncome,
                outgo: 0,
                category: "Old",
                ledgerIdentifier: owner
            ),
            repeatCount: Self.repeatCount
        )
        _ = try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Standard",
                income: Self.standardIncome,
                outgo: 0,
                category: "Old"
            ),
            repeatCount: 1
        )
        return (owner, try context.fetch(.items(.all, order: .forward, ledgerIdentifier: owner)))
    }

    func changedInput(for item: Item) -> ItemFormInput {
        .init(
            date: item.localDate,
            content: "Changed",
            income: Self.changedIncome,
            outgo: 0,
            category: "New",
            ledgerIdentifier: item.ledgerIdentifier
        )
    }

    func mutateAndSave(
        _ context: ModelContext,
        items: [Item],
        deleting: Bool
    ) throws -> MutationOutcome {
        if deleting {
            return try ItemDeletionOperations.deleteAndSaveWithOutcome(context: context, item: items[0])
        }
        return try ItemUpdateOperations.updateAndSaveWithOutcome(
            context: context,
            item: items[0],
            input: changedInput(for: items[0]),
            scope: .thisItem
        )
    }

    func verifyBalances(
        _ context: ModelContext,
        owner: LedgerIdentifier,
        expected: Decimal
    ) throws {
        let snapshot = try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: owner)
        #expect(snapshot.latestBalance == expected)
        for item in try context.fetch(.items(.all, ledgerIdentifier: owner)) {
            #expect(item.balance == snapshot.balances[item.id])
        }
    }

    func archive(_ context: ModelContext) throws -> [IncomesFileItem] {
        try ItemExportOperations.fileItems(items: context.fetch(.allLedgerItems()))
    }

    func container(at url: URL) throws -> ModelContainer {
        try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
    }

    func withStore(_ body: (URL) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try autoreleasepool {
            try body(directory.appendingPathComponent("Incomes.sqlite"))
        }
    }
}
