import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct LedgerIntegrationTests {
    private struct BackupFixture {
        let contents: IncomesFileContents
        let empty: LedgerRecord
        let identifiers: Set<LedgerIdentifier>
    }

    @Test
    func fourBookBackupRemapsStoreIDsAndKeepsEmptyBooksAndRepeatImportStable() throws {
        let fixture = try makeBackupFixture()
        let contents = fixture.contents
        let empty = fixture.empty
        #expect(contents.selectionLedgerIdentifiers.count == fixture.identifiers.count)
        #expect(contents.selectionLedgerIdentifiers.intersection(fixture.identifiers) == [.default])
        #expect(Set(contents.ledgers.map(\.id)).union([.default]) == contents.selectionLedgerIdentifiers)
        let container = try ModelContainerFactory.inMemory()
        let reviewContext = ModelContext(container)
        let difference = try ItemImportOperations.difference(contents: contents, context: reviewContext)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: reviewContext
        )
        let restored = ModelContext(container)
        let rows = try restored.fetch(.allLedgerItems())
        let physicalIDs = Set(rows.map(\.persistentModelID))
        #expect(rows.count == 6)
        #expect(try LedgerOperations.ledgers(context: restored).count == 4)
        let restoredEmpty = try #require(
            try LedgerOperations.ledgers(context: restored).first { $0.name == empty.name }
        )
        #expect(restoredEmpty.id != empty.id)
        #expect(
            try LedgerBalanceOperations.snapshot(context: restored, ledgerIdentifier: restoredEmpty.id)
                .latestBalance == .zero
        )
        let repeated = try ItemImportOperations.difference(contents: contents, context: restored)
        #expect(repeated.isIdentical)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents,
            reviewed: repeated,
            policy: .merge(.init()),
            context: restored
        )
        #expect(
            try Set(ModelContext(container).fetch(.allLedgerItems()).map(\.persistentModelID)) == physicalIDs
        )
    }

    @Test
    func replacingOneBookDoesNotRemoveTheOtherBooks() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let ledger = try LedgerOperations.create(context: context, name: "Other")
        let standard = try item(context: context)
        _ = try item(context: context, owner: ledger.id)
        try context.save()
        let contents = IncomesFileContents(
            formatVersion: 1,
            schemaVersion: "2.0.0",
            exportedAt: .now,
            currencyCode: nil,
            items: [],
            ledgers: [.init(id: ledger.id, name: ledger.name)],
            selectionLedgerIdentifiers: [ledger.id]
        )
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(
            ItemImportOperations.mutatedLedgerIdentifiers(difference: difference, policy: .replace) == [
                ledger.id
            ]
        )
        #expect(
            ItemImportOperations.mutatedLedgerIdentifiers(difference: difference, policy: .merge(.init()))
                .isEmpty
        )
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: context
        )
        try context.save()
        #expect(try context.fetchCount(.items(.all, ledgerIdentifier: ledger.id)) == 0)
        #expect(try context.fetch(.items(.all)).map(\.persistentModelID) == [standard.persistentModelID])
    }

    @Test
    func fullBackupIncludesAnEmptyDefaultBookInItsReplacementScope() throws {
        let incoming = IncomesFileLedger(id: LedgerIdentifier(), name: "Empty")
        let bytes = try ItemExportOperations.incomesFileData(
            fileItems: [], currencyCode: "JPY", ledgers: [incoming]
        )
        let contents = try ItemImportOperations.read(data: bytes)
        #expect(contents.selectionLedgerIdentifiers == [.default, incoming.id])
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let unselected = try LedgerOperations.create(context: context, name: "Unselected")
        _ = try item(context: context)
        let retained = try item(context: context, owner: unselected.id)
        try context.save()
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .replace,
            context: context
        )
        #expect(try context.fetchCount(.items(.all)) == 0)
        #expect(try context.fetch(.allLedgerItems()).map(\.persistentModelID) == [retained.persistentModelID])
        #expect(try LedgerOperations.ledgers(context: context).contains { $0.name == incoming.name && $0.isAvailable })
    }

    @Test
    func aMetadataOnlyMergeRequiresAnExplicitChoiceToReplaceNames() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let ledger = try LedgerOperations.create(context: context, name: "Original")
        let incoming = IncomesFileLedger(
            id: ledger.id,
            name: "From File"
        )
        let contents = IncomesFileContents(
            formatVersion: 1,
            schemaVersion: "2.0.0",
            exportedAt: .now,
            currencyCode: nil,
            items: [],
            ledgers: [incoming],
            selectionLedgerIdentifiers: [ledger.id]
        )
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        let keep = ItemImportPolicy.merge(.init())
        let useFile = ItemImportPolicy.merge(.init(useFileLedgerNames: true))
        #expect(ItemImportOperations.mutatedLedgerIdentifiers(difference: difference, policy: keep).isEmpty)
        #expect(
            ItemImportOperations.mutatedLedgerIdentifiers(difference: difference, policy: useFile) == [
                ledger.id
            ]
        )
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: keep,
            context: context
        )
        try context.save()
        #expect(try LedgerOperations.ledger(ledger.id, context: context).name == "Original")
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: useFile,
            context: context
        )
        try context.save()
        #expect(
            try LedgerOperations.ledger(ledger.id, context: context).name == incoming.name
        )
    }

    @Test
    func duplicationAndExternalItemLinksStayWithTheirOwner() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let ledger = try LedgerOperations.create(context: context, name: "Other")
        let series = UUID()
        for owner in [LedgerIdentifier.default, ledger.id] {
            for month in 1...3 { _ = try item(context: context, owner: owner, month: month, series: series) }
        }
        try context.save()
        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_025,
            targetYear: 2_026,
            ledgerIdentifier: ledger.id
        )
        #expect(plan.entries.count == 3)
        #expect(plan.entries.allSatisfy { $0.sourceItem.ledgerIdentifier == ledger.id })
        let group = try #require(plan.groups.first)
        #expect(
            YearlyItemDuplicationPlanOperations.draft(for: group.id, in: plan)?.ledgerIdentifier == ledger.id
        )
        _ = try YearlyItemDuplicationApplyOperations.apply(plan: plan, context: context)
        try context.save()
        #expect(try context.fetchCount(.items(.all)) == 3)
        #expect(try context.fetchCount(.items(.all, ledgerIdentifier: ledger.id)) == 6)
        let sourceItem = try #require(plan.entries.first?.sourceItem)
        #expect(
            MainNavigationOperations.ledgerIdentifier(forExternalRoute: .item("invalid"), context: context)
                == .default
        )
        let encoded = try PersistentIdentifierCoder.encode(sourceItem.persistentModelID)
        #expect(
            MainNavigationOperations.ledgerIdentifier(forExternalRoute: .item(encoded), context: context)
                == ledger.id
        )
        #expect(
            MainNavigationOperations.ledgerIdentifier(
                forExternalRoute: .month(year: 2_026, month: 1),
                context: context
            ) == .default
        )
    }

    @Test
    func lapseKeepsTheDefaultEditableAndBlocksAdditionalBookWrites() throws {
        let other = LedgerIdentifier()
        #expect(LedgerAccessOperations.canEdit(.default, isPremium: false))
        #expect(!LedgerAccessOperations.canEdit(other, isPremium: false))
        #expect(LedgerAccessOperations.canEdit(other, isPremium: true))
        #expect(throws: LedgerError.premiumRequired) {
            try LedgerAccessOperations.requireEditing([.default, other], isPremium: false)
        }
        #expect(throws: LedgerError.premiumRequired) {
            try LedgerAccessOperations.requireCreation(isPremium: false)
        }
    }

    private func makeBackupFixture() throws -> BackupFixture {
        let source = ModelContext(try ModelContainerFactory.inMemory())
        let first = try LedgerOperations.create(context: source, name: "Personal")
        let second = try LedgerOperations.create(context: source, name: "Business")
        let empty = try LedgerOperations.create(context: source, name: "Savings")
        let series = UUID()
        for owner in [LedgerIdentifier.default, first.id, second.id] {
            for month in 1...2 {
                _ = try item(context: source, owner: owner, month: month, series: series)
            }
        }
        try source.save()
        let bytes = try ItemExportOperations.incomesFileData(
            fileItems: ItemExportOperations.fileItems(items: source.fetch(.allLedgerItems())),
            currencyCode: "JPY",
            ledgers: ItemExportOperations.fileLedgers(context: source)
        )
        let contents = try ItemImportOperations.read(data: bytes)
        return .init(
            contents: contents,
            empty: empty,
            identifiers: [.default, first.id, second.id, empty.id]
        )
    }
}

private extension LedgerIntegrationTests {
    func item(
        context: ModelContext,
        owner: LedgerIdentifier = .default,
        month: Int = 1,
        series: UUID = UUID()
    ) throws -> Item {
        let date = shiftedDate(String(format: "2025-%02d-01T00:00:00Z", month))
        return try Item.create(
            context: context,
            values: .init(
                date: date,
                content: "Plan",
                income: 100,
                outgo: .zero,
                category: "Same",
                priority: .zero,
                ledgerIdentifier: owner
            ),
            repeatID: series
        )
    }
}
