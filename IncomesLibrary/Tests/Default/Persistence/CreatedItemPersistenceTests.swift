import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct CreatedItemPersistenceTests {
    @Test(arguments: [false, true])
    func yearly_duplication_returns_persisted_ids_and_respects_group_selection(singleGroup: Bool) throws {
        try SaveFailureFixture.withStore { fixture in
            let context = fixture.context
            try seedYearlyGroups(context: context)
            let originalIDs = try itemIDs(context)
            let plan = try YearlyItemDuplicationPlanOperations.plan(
                context: context,
                sourceYear: TestValue.sourceYear,
                targetYear: TestValue.targetYear,
                options: .init(minimumRepeatItemCount: TestValue.repeatCount)
            )
            #expect(plan.groups.count == 2)
            let result: MutationResult<YearlyItemDuplicationResult>
            if singleGroup {
                let group = try #require(plan.groups.first)
                result = try #require(try YearlyItemDuplicationApplyOperations.applyAndSaveWithOutcome(
                    groupID: group.id, in: plan, context: context
                ))
            } else {
                result = try YearlyItemDuplicationApplyOperations.applyAndSaveWithOutcome(plan: plan, context: context)
            }
            #expect(!context.hasChanges)
            let reopened = try fixture.reopenedContext()
            let allIDs = try itemIDs(reopened)
            #expect(originalIDs.isSubset(of: allIDs))
            let createdIDs = try Set(result.outcome.changedIDs.created.map(PersistentIdentifierCoder.encode))
            #expect(createdIDs == allIDs.subtracting(originalIDs))
            #expect(createdIDs.count == (singleGroup ? TestValue.repeatCount : TestValue.allCreatedCount))
            #expect(try MutationStoreSnapshot(context: reopened) == MutationStoreSnapshot(context: context))
        }
    }

    @Test(arguments: [false, true])
    func watch_snapshot_returns_persisted_ids_after_replacing_the_cache(empty: Bool) throws {
        try SaveFailureFixture.withStore { fixture in
            let context = fixture.context
            try seedCache(context: context)
            let originalIDs = Set(try context.fetch(.allLedgerItems()).map(\.id))
            let items: [ItemWire] = empty ? [] : [.init(
                dateEpoch: shiftedDate("2000-01-02T12:00:00Z").timeIntervalSince1970,
                content: "New cache",
                income: TestValue.snapshotIncome,
                outgo: TestValue.snapshotOutgo,
                category: "New"
            )]
            let outcome = try WatchSyncOperations.applySnapshotAndSave(
                context: context,
                items: items,
                baseDate: shiftedDate("2000-01-01T12:00:00Z"),
                monthOffsets: [0]
            )
            #expect(!context.hasChanges)
            let reopened = try fixture.reopenedContext()
            let savedItems = try reopened.fetch(.allLedgerItems())
            #expect(try Set(outcome.changedIDs.created.map(PersistentIdentifierCoder.encode)) == itemIDs(reopened))
            #expect(outcome.changedIDs.deleted == originalIDs)
            #expect(savedItems.count == (empty ? 0 : 1))
            #expect(try MutationStoreSnapshot(context: reopened) == MutationStoreSnapshot(context: context))
        }
    }
}

private extension CreatedItemPersistenceTests {
    enum TestValue {
        static let repeatCount = 2
        static let allCreatedCount = 4
        static let sourceYear = 2_000
        static let targetYear = 2_001
        static let snapshotIncome = 50.0
        static let snapshotOutgo = 10.0
    }

    func itemIDs(_ context: ModelContext) throws -> Set<String> {
        try Set(context.fetch(.allLedgerItems()).map { try PersistentIdentifierCoder.encode($0.id) })
    }

    func seedYearlyGroups(context: ModelContext) throws {
        for content in ["Rent", "Salary"] {
            _ = try ItemCreationOperations.createAndSaveWithOutcome(
                context: context,
                input: .init(
                    date: shiftedDate("2000-01-01T12:00:00Z"),
                    content: content,
                    income: 100,
                    outgo: 0,
                    category: content
                ),
                repeatCount: TestValue.repeatCount
            )
        }
    }

    func seedCache(context: ModelContext) throws {
        _ = try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Old cache",
                income: 100,
                outgo: 0,
                category: "Old"
            ),
            repeatCount: 1
        )
    }
}
