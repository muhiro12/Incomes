import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerOwnershipTests {
    @Test(arguments: ["", "5.12", "5.3"])
    func firstLegacyLaunchAssignsExistingRecordsWithoutChangingFinancialData(version: String) throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let item = try makeItem(context, income: 120)
        removeOwnership(item)
        for tag in try context.fetch(.tags(.typeIs(.defaultLedger))) {
            context.delete(tag)
        }
        try context.save()
        let before = IncomesFileItem(item: item)
        let identifier = item.persistentModelID
        let outcome = try LedgerOperations.prepareDefaultLedger(context: context, lastLaunchedAppVersion: version)
        #expect(item.ledgerIdentifier == .default)
        #expect(item.persistentModelID == identifier)
        #expect(IncomesFileItem(item: item).assigning(to: .unassigned) == before)
        #expect(outcome.changedIDs.updated == [identifier])
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == 120)
        #expect(!context.hasChanges)
    }

    @Test(arguments: ["6.0", "6.1"])
    func currentLaunchDoesNotRepeatLegacyMigration(version: String) throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let item = try makeItem(context, income: 120)
        try context.save()
        removeOwnership(item)
        try context.save()
        try LedgerOperations.prepareDefaultLedger(context: context, lastLaunchedAppVersion: version)
        #expect(item.ledgerIdentifier == .unassigned)
        #expect(try context.fetchCount(.items(.all)) == 0)
        #expect(!context.hasChanges)
    }

    @Test
    func aSyncedStandardTagDoesNotBlockTheOtherDevicesLegacyUpgrade() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let item = try makeItem(context, income: 120)
        removeOwnership(item)
        try context.save()
        #expect(try context.fetchCount(.tags(.typeIs(.defaultLedger))) == 1)
        try LedgerOperations.prepareDefaultLedger(context: context, lastLaunchedAppVersion: "5.12")
        #expect(item.ledgerIdentifier == .default)
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == 120)
        #expect(!context.hasChanges)
    }

    @Test
    func additionalMetadataPreventsGuessingTheOwnerOfALegacyRecord() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        _ = try LedgerOperations.create(context: context, name: "Savings")
        let item = try makeItem(context, income: 120)
        removeOwnership(item)
        for tag in try context.fetch(.tags(.typeIs(.defaultLedger))) {
            context.delete(tag)
        }
        try context.save()
        try LedgerOperations.prepareDefaultLedger(context: context, lastLaunchedAppVersion: "5.12")
        #expect(item.ledgerIdentifier == .unassigned)
    }

    @Test
    func delayedUntaggedRecordsAndLostMembershipAreDetectedWithoutRepairingOwnership() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        try LedgerOperations.prepareDefaultLedger(context: context, lastLaunchedAppVersion: "")
        let standard = try makeItem(context, income: 10)
        let late = try makeItem(context, income: 90)
        removeOwnership(late)
        try context.save()
        try LedgerOperations.prepareDefaultLedger(context: context, lastLaunchedAppVersion: "6.0")
        try ItemBalanceOperations.reconcileAndSave(context: context)
        #expect(standard.ledgerIdentifier == .default)
        #expect(late.ledgerIdentifier == .unassigned)
        #expect(try context.fetch(.items(.all)).map(\.id) == [standard.id])
        #expect(try context.fetch(.items(.all, ledgerIdentifier: .unassigned)).map(\.id) == [late.id])
        #expect(try LedgerOperations.ledgers(context: context).contains { $0.id == .unassigned })
        #expect(throws: LedgerError.missingOwnership) {
            try LedgerBalanceOperations.snapshot(context: context)
        }
        #expect(throws: LedgerError.missingOwnership) {
            try ItemSummaryOperations.monthlyTotals(context: context, date: .now)
        }
        #expect(throws: LedgerError.missingOwnership) {
            try WatchSyncOperations.recentItemWires(context: context, baseDate: .now)
        }
        let deepLink = try #require(URL(string: "incomes://home"))
        let widget = WidgetEntryOperations.monthSummarySnapshot(context: context, date: .now) { _ in
            deepLink
        }
        #expect(widget.totalIncomeText == ItemSummaryOperations.unavailableAmountText)
        #expect(!context.hasChanges)
    }

    @Test
    func explicitAssignmentKeepsTheRecordAndOnlyChangesSelectedOwnership() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let ledger = try LedgerOperations.create(context: context, name: "Savings")
        let first = try makeItem(context, income: 10)
        let second = try makeItem(context, income: 90)
        removeOwnership(first)
        removeOwnership(second)
        try context.save()
        let identifier = first.id
        let before = IncomesFileItem(item: first)
        let outcome = try LedgerOperations.assignUnassignedItems(itemIDs: [first.id], to: ledger.id, context: context)
        #expect(first.id == identifier)
        #expect(IncomesFileItem(item: first).assigning(to: .unassigned) == before)
        #expect(outcome.changedIDs.updated == [identifier])
        #expect(first.ledgerIdentifier == ledger.id)
        #expect(second.ledgerIdentifier == .unassigned)
        try LedgerOperations.assignUnassignedItems(itemIDs: [second.id], to: .default, context: context)
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == 90)
        #expect(try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: ledger.id).latestBalance == 10)
        #expect(!context.hasChanges)
    }

    @Test
    func oldWriterLosingAdditionalOwnershipNeverMovesTheItemToTheDefaultLedger() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let owner = try LedgerOperations.create(context: context, name: "Savings").id
        let item = try Item.create(
            context: context,
            values: .init(
                date: .now,
                content: "Savings",
                income: 80,
                outgo: 0,
                category: "Work",
                priority: 0,
                ledgerIdentifier: owner
            ),
            repeatID: UUID()
        )
        try context.save()
        let identifier = item.id
        removeOwnership(item)
        try context.save()
        try LedgerOperations.prepareDefaultLedger(context: context, lastLaunchedAppVersion: "5.12")
        #expect(item.ledgerIdentifier == .unassigned)
        #expect(try context.fetchCount(.items(.all)) == 0)
        #expect(try context.fetchCount(.items(.all, ledgerIdentifier: owner)) == 0)
        #expect(throws: LedgerError.missingOwnership) {
            try ItemExportOperations.incomesFileData(
                fileItems: ItemExportOperations.fileItems(items: [item]),
                currencyCode: "JPY"
            )
        }
        try LedgerOperations.assignUnassignedItems(itemIDs: [identifier], to: owner, context: context)
        #expect(item.id == identifier)
        #expect(item.ledgerIdentifier == owner)
        #expect(try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: owner).latestBalance == 80)
    }

    @Test
    func changedSelectionIsRefusedWithoutReassigningOtherItems() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let first = try makeItem(context, income: 10)
        let second = try makeItem(context, income: 90)
        removeOwnership(first)
        try context.save()
        #expect(throws: LedgerError.ownershipChanged) {
            try LedgerOperations.assignUnassignedItems(itemIDs: [first.id, second.id], to: .default, context: context)
        }
        #expect(first.ledgerIdentifier == .unassigned)
        #expect(second.ledgerIdentifier == .default)
        #expect(!context.hasChanges)
    }

    @Test
    func failedBalanceValidationLeavesUnassignedItemsAndMetadataUntouched() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        _ = try makeItem(context, income: Decimal(sign: .plus, exponent: 40, significand: 1))
        let unassigned = try makeItem(context, income: 1)
        removeOwnership(unassigned)
        try context.save()
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try LedgerOperations.assignUnassignedItems(itemIDs: [unassigned.id], to: .default, context: context)
        }
        #expect(unassigned.ledgerIdentifier == .unassigned)
        #expect(try context.fetchCount(.allLedgerItems()) == 2)
        #expect(!context.hasChanges)
    }

    @Test
    func currentLaunchDoesNotReclassifyRecordsWhenOwnershipMetadataIsMissing() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let item = try makeItem(context, income: 10)
        removeOwnership(item)
        for tag in try context.fetch(.tags(.typeIs(.defaultLedger))) {
            context.delete(tag)
        }
        try context.save()
        try LedgerOperations.prepareDefaultLedger(context: context, lastLaunchedAppVersion: "6.0")
        #expect(item.ledgerIdentifier == .unassigned)
        #expect(!context.hasChanges)
    }

    @Test
    func defaultTagDuplicatesDescribeOneRoleAndSurviveClassificationMaintenance() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let item = try makeItem(context, income: 10)
        let duplicate = Tag.createIgnoringDuplicates(context: context, name: "Default Ledger", type: .defaultLedger)
        item.modify(tags: (item.tags ?? []) + [duplicate])
        try context.save()
        #expect(item.ledgerIdentifier == .default)
        #expect(try TagQueryOperations.hasDuplicates(context: context) == false)
        #expect(try TagMutationOperations.resolveAllDuplicates(context: context) == 0)
        #expect(try TagMutationOperations.deleteAllOrphanTags(context: context) == 0)
        #expect(TagMutationOperations.delete(tag: duplicate) == false)
        #expect(try context.fetchCount(.tags(.typeIs(.defaultLedger))) == 2)
    }

    @Test
    func defaultAndAdditionalOwnershipConflictInsteadOfFavoringEitherLedger() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let ledger = try LedgerOperations.create(context: context, name: "Savings")
        let item = try makeItem(context, income: 10)
        item.modify(tags: (item.tags ?? []) + [try LedgerOperations.metadataForMutation(ledger.id, context: context)])
        try context.save()
        #expect(item.ledgerIdentifier == .conflicting)
        #expect(try context.fetchCount(.defaultLedgerItems(.all)) == 0)
        #expect(try context.fetchCount(.items(.all, ledgerIdentifier: ledger.id)) == 0)
    }

    private func makeItem(_ context: ModelContext, income: Decimal) throws -> Item {
        try Item.create(
            context: context,
            values: .init(date: .now, content: "Existing", income: income, outgo: 0, category: "Work", priority: 0),
            repeatID: UUID()
        )
    }

    private func removeOwnership(_ item: Item) {
        item.modify(tags: (item.tags ?? []).filter { $0.type?.isLedgerOwnership != true })
    }
}
