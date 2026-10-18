import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct MutationSaveFailureTests {
    enum Change: CaseIterable, Sendable {
        case create
        case update
        case delete
        case reset
        case debugCleanup
        case orphanCleanup
        case orphanDelete
        case mergeTags
        case yearlyDuplication
        case watchSnapshot
        case sampleCreation
    }

    @Test(arguments: Change.allCases, [false, true])
    func a_real_save_failure_preserves_the_store_and_a_writable_retry_commits(
        change: Change,
        autosaveEnabled: Bool
    ) throws {
        try SaveFailureFixture.withStore { fixture in
            try seed(context: fixture.context)
            let before = try MutationStoreSnapshot(context: fixture.context)
            let failing = try fixture.readOnlyContext()
            failing.autosaveEnabled = autosaveEnabled
            fixture.observeSaves(in: failing)
            var finishedStaging = false
            #expect(throws: (any Error).self) {
                // Exercise the commit phase directly so read-only preflight cannot
                // replace the real ModelContext.save() failure under test.
                try MutationPersistenceSupport.commit(context: failing) {
                    try stage(change, context: failing)
                    finishedStaging = true
                }
            }
            #expect(finishedStaging)
            #expect(fixture.saveAttempts == 1)
            #expect(!failing.hasChanges)
            #expect(failing.autosaveEnabled == autosaveEnabled)
            // Read-only mutation bypass is unsupported on iOS 18: rollback may
            // invalidate its live graph. The public preflight is tested below.
            if #available(iOS 27, *) {
                #expect(try MutationStoreSnapshot(context: failing) == before)
            }
            #expect(try MutationStoreSnapshot(context: fixture.reopenedContext()) == before)

            let retry = try fixture.reopenedContext()
            retry.autosaveEnabled = autosaveEnabled
            try commit(change, context: retry)
            #expect(!retry.hasChanges)
            #expect(retry.autosaveEnabled == autosaveEnabled)
            let saved = try MutationStoreSnapshot(context: retry)
            #expect(saved != before)
            #expect(try MutationStoreSnapshot(context: fixture.reopenedContext()) == saved)
            try verifyCommitted(change, context: retry)
        }
    }

    @Test(arguments: Change.allCases)
    func public_mutations_preserve_unrelated_pending_edits(change: Change) throws {
        try SaveFailureFixture.withStore { fixture in
            let context = fixture.context
            try seed(context: context)
            let saved = try MutationStoreSnapshot(context: context)
            let item = try #require(try context.fetch(.allLedgerItems()).first { $0.content == "Standard" })
            try item.modify(
                values: .init(
                    date: item.localDate,
                    content: "Unsaved draft",
                    income: item.income,
                    outgo: item.outgo,
                    category: "Draft",
                    priority: item.priority,
                    ledgerIdentifier: item.ledgerIdentifier
                ),
                repeatID: item.repeatID
            )
            let draft = try MutationStoreSnapshot(context: context)
            #expect(throws: (any Error).self) {
                try commit(change, context: context)
            }
            #expect(context.hasChanges)
            #expect(try MutationStoreSnapshot(context: context) == draft)
            #expect(try MutationStoreSnapshot(context: fixture.reopenedContext()) == saved)
            context.rollback()
        }
    }

    @Test(arguments: Change.allCases)
    func public_read_only_preflight_refuses_before_mutating_or_saving(change: Change) throws {
        try SaveFailureFixture.withStore { fixture in
            try seed(context: fixture.context)
            let context = try fixture.readOnlyContext()
            let before = try MutationStoreSnapshot(context: context)
            fixture.observeSaves(in: context)
            #expect(throws: (any Error).self) {
                try commit(change, context: context)
            }
            #expect(fixture.saveAttempts == 0)
            #expect(!context.hasChanges)
            #expect(try MutationStoreSnapshot(context: context) == before)
        }
    }

    @Test
    func single_tag_deletion_preserves_referenced_metadata_and_foreign_contexts() throws {
        try SaveFailureFixture.withStore { fixture in
            let context = fixture.context
            try seed(context: context)
            let before = try MutationStoreSnapshot(context: context)
            let owner = try #require(try context.fetch(.tags(.nameIs("Empty", type: .ledger))).first)
            #expect(try TagMutationOperations.deleteAndSave(context: context, tag: owner) == false)
            let used = try #require(try duplicates(context).first)
            #expect(try TagMutationOperations.deleteAndSave(context: context, tag: used) == false)
            let foreignContext = try fixture.reopenedContext()
            #expect(try TagMutationOperations.deleteAndSave(context: foreignContext, tag: orphan(context)) == false)
            #expect(!context.hasChanges)
            #expect(try MutationStoreSnapshot(context: context) == before)
        }
    }
}

private extension MutationSaveFailureTests {
    enum TestValue {
        static let standardIncome = 90
        static let updatedIncome = 125
        static let createdIncome = 25
        static let snapshotIncome = 70
        static let snapshotOutgo = 20
        static let snapshotBalance = 50
        static let sourceYear = 2_000
        static let targetYear = 2_001
        static let repeatCount = 2
        static let initialItemCount = 3
        static let afterDebugCleanupCount = 2
    }

    func seed(context: ModelContext) throws {
        let owner = try LedgerOperations.create(context: context, name: "Additional").id
        _ = try LedgerOperations.create(context: context, name: "Empty")
        _ = try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Original",
                income: 100,
                outgo: 0,
                category: "Old",
                ledgerIdentifier: owner
            ),
            repeatCount: TestValue.repeatCount
        )
        _ = try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Standard",
                income: Decimal(TestValue.standardIncome),
                outgo: 0,
                category: "Other"
            ),
            repeatCount: 1
        )
        let item = try target(context)
        let duplicate = Tag.createIgnoringDuplicates(context: context, name: "Old", type: .category)
        let debug = Tag.createIgnoringDuplicates(context: context, name: "Sample", type: .debug)
        item.modify(tags: (item.tags ?? []).filter { $0.type != .category } + [duplicate, debug])
        _ = Tag.createIgnoringDuplicates(context: context, name: "Unused", type: .category)
        _ = Tag.createIgnoringDuplicates(context: context, name: "Unused 2", type: .content)
        try context.save()
    }

    func target(_ context: ModelContext) throws -> Item {
        try #require(try context.fetch(.allLedgerItems()).filter { $0.content == "Original" }.min())
    }

    func orphan(_ context: ModelContext) throws -> IncomesLibrary.Tag {
        try #require(try context.fetch(.tags(.nameIs("Unused", type: .category))).first)
    }

    func duplicates(_ context: ModelContext) throws -> [IncomesLibrary.Tag] {
        try context.fetch(.tags(.nameIs("Old", type: .category)))
    }

    func changedInput(for item: Item) -> ItemFormInput {
        .init(
            date: item.localDate,
            content: "Changed",
            income: Decimal(TestValue.updatedIncome),
            outgo: 0,
            category: "New",
            ledgerIdentifier: item.ledgerIdentifier
        )
    }

    func creationInput() -> ItemFormInput {
        .init(
            date: shiftedDate("2000-03-01T12:00:00Z"),
            content: "Created",
            income: Decimal(TestValue.createdIncome),
            outgo: 0,
            category: "New"
        )
    }

    func yearlyPlan(_ context: ModelContext) throws -> YearlyItemDuplicationPlan {
        try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: TestValue.sourceYear,
            targetYear: TestValue.targetYear,
            options: .init(includeSingleItems: true, minimumRepeatItemCount: TestValue.repeatCount)
        )
    }

    func wire() -> ItemWire {
        .init(
            dateEpoch: shiftedDate("2000-01-03T12:00:00Z").timeIntervalSince1970,
            content: "Snapshot",
            income: Double(TestValue.snapshotIncome),
            outgo: Double(TestValue.snapshotOutgo),
            category: "Watch"
        )
    }

    func stage(_ change: Change, context: ModelContext) throws {
        switch change {
        case .create:
            _ = try ItemCreationOperations.createWithOutcome(context: context, input: creationInput(), repeatCount: 1)
        case .update:
            let item = try target(context)
            _ = try ItemUpdateOperations.updateWithOutcome(
                context: context, item: item, input: changedInput(for: item), scope: .thisItem
            )
        case .delete:
            _ = try ItemDeletionOperations.deleteWithOutcome(context: context, item: target(context))
        case .reset, .debugCleanup:
            try stageMaintenance(change, context: context)
        case .orphanCleanup:
            try TagMutationOperations.deleteAllOrphanTags(context: context)
        case .orphanDelete:
            #expect(TagMutationOperations.delete(tag: try orphan(context)))
        case .mergeTags:
            try TagMutationOperations.resolveDuplicates(context: context, tags: duplicates(context))
        case .yearlyDuplication:
            _ = try YearlyItemDuplicationApplyOperations.applyWithOutcome(plan: yearlyPlan(context), context: context)
        case .watchSnapshot:
            _ = try WatchSyncOperations.applySnapshot(
                context: context, items: [wire()], baseDate: shiftedDate("2000-01-01T12:00:00Z"), monthOffsets: [0]
            )
        case .sampleCreation:
            try SampleDataOperations.seed(
                context: context, profile: .minimal, baseDate: shiftedDate("2000-04-01T12:00:00Z")
            )
        }
    }

    func commit(_ change: Change, context: ModelContext) throws {
        switch change {
        case .create:
            _ = try ItemCreationOperations.createAndSaveWithOutcome(
                context: context, input: creationInput(), repeatCount: 1
            )
        case .update:
            let item = try target(context)
            _ = try ItemUpdateOperations.updateAndSaveWithOutcome(
                context: context, item: item, input: changedInput(for: item), scope: .thisItem
            )
        case .delete:
            _ = try ItemDeletionOperations.deleteAndSaveWithOutcome(context: context, item: target(context))
        case .reset, .debugCleanup:
            try commitMaintenance(change, context: context)
        case .orphanCleanup:
            try TagMutationOperations.deleteAllOrphanTagsAndSave(context: context)
        case .orphanDelete:
            #expect(try TagMutationOperations.deleteAndSave(context: context, tag: orphan(context)))
        case .mergeTags:
            try TagMutationOperations.resolveDuplicatesAndSave(context: context, tags: duplicates(context))
        case .yearlyDuplication:
            _ = try YearlyItemDuplicationApplyOperations.applyAndSaveWithOutcome(
                plan: yearlyPlan(context), context: context
            )
        case .watchSnapshot:
            _ = try WatchSyncOperations.applySnapshotAndSave(
                context: context, items: [wire()], baseDate: shiftedDate("2000-01-01T12:00:00Z"), monthOffsets: [0]
            )
        case .sampleCreation:
            try SampleDataOperations.seedAndSave(
                context: context, profile: .minimal, baseDate: shiftedDate("2000-04-01T12:00:00Z")
            )
        }
    }

    func stageMaintenance(_ change: Change, context: ModelContext) throws {
        if change == .reset {
            try DataMaintenanceOperations.deleteAllData(context: context)
        } else {
            try DataMaintenanceOperations.deleteDebugData(context: context)
        }
    }

    func commitMaintenance(_ change: Change, context: ModelContext) throws {
        if change == .reset {
            try DataMaintenanceOperations.deleteAllDataAndSave(context: context)
        } else {
            try DataMaintenanceOperations.deleteDebugDataAndSave(context: context)
        }
    }

    func verifyCommitted(_ change: Change, context: ModelContext) throws {
        let items = try context.fetch(.allLedgerItems())
        if change == .reset {
            #expect(items.isEmpty)
            #expect(try context.fetchCount(.tags(.all)) == 0)
            return
        }
        #expect(try LedgerOperations.ledgers(context: context).contains { $0.name == "Empty" })
        if change == .watchSnapshot {
            #expect(items.count == 1)
            #expect(items.first?.content == "Snapshot")
            #expect(items.first?.balance == Decimal(TestValue.snapshotBalance))
            return
        }
        #expect(items.contains { item in
            item.content == "Standard"
                && item.income == Decimal(TestValue.standardIncome)
                && item.ledgerIdentifier == .default
        })
        if change == .orphanCleanup || change == .orphanDelete || change == .mergeTags {
            #expect(items.count == TestValue.initialItemCount)
        }
        if change == .orphanCleanup {
            #expect(try TagQueryOperations.orphanTags(context: context).isEmpty)
        }
        if change == .mergeTags {
            #expect(try duplicates(context).count == 1)
        }
        if change == .debugCleanup {
            #expect(items.count == TestValue.afterDebugCleanupCount)
            #expect(try SampleDataOperations.hasDebugData(context: context) == false)
        }
        for ledger in try LedgerOperations.ledgers(context: context) where ledger.isAvailable {
            let snapshot = try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: ledger.id)
            for item in items where item.ledgerIdentifier == ledger.id {
                #expect(item.balance == snapshot.balances[item.id])
            }
        }
    }
}
