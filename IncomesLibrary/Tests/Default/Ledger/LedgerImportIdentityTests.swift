import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerImportIdentityTests {
    private let plannedTimeInterval: TimeInterval = 1_735_689_600

    @Test
    func exportReferencesHideStoreIDsAndRecognizeTheSameLedgerAfterRename() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let ledger = try LedgerOperations.create(context: context, name: "Original")
        _ = try makeItem(context: context, owner: ledger.id, income: 100)
        try context.save()
        let contents = try exportedContents(context)
        let reference = try #require(contents.ledgers.first?.id)
        #expect(reference != ledger.id)
        #expect(throws: PersistentIdentifierCoder.Error.self) {
            try PersistentIdentifierCoder.decode(reference.rawValue)
        }
        #expect(contents.items.first?.ledgerIdentifier == reference)
        try LedgerOperations.rename(ledger.id, to: "Renamed", context: context)
        #expect(try exportedContents(context).ledgers.first?.id == reference)
        let review = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(review.additions.isEmpty && review.storeOnlyItems.isEmpty)
        #expect(review.ledgerChanges.first?.id == ledger.id)
        #expect(review.ledgerChanges.first?.current?.name == "Renamed")
        #expect(review.ledgerChanges.first?.incoming.name == "Original")
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 1)
    }

    @Test
    func anExportResolvesToTheDestinationTagWithoutInstallingSourceModelIDs() throws {
        let source = ModelContext(try ModelContainerFactory.inMemory())
        let sourceLedger = try LedgerOperations.create(context: source, name: "Business")
        _ = try makeItem(context: source, owner: sourceLedger.id, income: 100)
        try source.save()
        let contents = try exportedContents(source)

        let destination = ModelContext(try ModelContainerFactory.inMemory())
        let destinationLedger = try LedgerOperations.create(context: destination, name: "Business")
        _ = try makeItem(context: destination, owner: destinationLedger.id, income: 40)
        try destination.save()
        #expect(sourceLedger.id != destinationLedger.id)
        let difference = try ItemImportOperations.difference(contents: contents, context: destination)
        #expect(difference.storeItemCount == 1)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents, reviewed: difference, policy: .replace, context: destination
        )
        let reader = ModelContext(destination.container)
        #expect(try reader.fetchCount(.tags(.typeIs(.ledger))) == 1)
        #expect(
            try LedgerBalanceOperations.snapshot(context: reader, ledgerIdentifier: destinationLedger.id)
                .latestBalance == 100
        )
        #expect(try ItemImportOperations.difference(contents: contents, context: reader).isIdentical)
    }

    @Test
    func restoringAccidentalDuplicatesPreservesDistinctMembershipAndRefusesAmbiguousRepeatImport() throws {
        let source = ModelContext(try ModelContainerFactory.inMemory())
        let first = Tag.createIgnoringDuplicates(context: source, name: "Same", type: .ledger)
        let second = Tag.createIgnoringDuplicates(context: source, name: "Same", type: .ledger)
        try source.save()
        _ = try makeItem(context: source, owner: #require(LedgerOperations.identifier(for: first)), income: 10)
        _ = try makeItem(context: source, owner: #require(LedgerOperations.identifier(for: second)), income: 20)
        try source.save()
        let contents = try exportedContents(source)
        let destination = ModelContext(try ModelContainerFactory.inMemory())
        let difference = try ItemImportOperations.difference(contents: contents, context: destination)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents, reviewed: difference, policy: .replace, context: destination
        )
        let reader = ModelContext(destination.container)
        let ledgers = try LedgerOperations.ledgers(context: reader).filter { $0.id != .default }
        #expect(ledgers.count == 2)
        let balances = try ledgers.map { ledger in
            try LedgerBalanceOperations.snapshot(context: reader, ledgerIdentifier: ledger.id).latestBalance
        }
        #expect(Set(balances) == [10, 20])
        let before = try ItemExportOperations.fileItems(items: reader.fetch(.allLedgerItems()))
        #expect(throws: LedgerError.duplicateIdentifier) {
            try ItemImportOperations.difference(contents: contents, context: reader)
        }
        #expect(try ItemExportOperations.fileItems(items: reader.fetch(.allLedgerItems())) == before)
        #expect(!reader.hasChanges)
    }

    @Test
    func unrepresentableLedgerMergeIsRefusedBeforeChangingMembership() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let first = Tag.createIgnoringDuplicates(context: context, name: "Same", type: .ledger)
        let second = Tag.createIgnoringDuplicates(context: context, name: "Same", type: .ledger)
        try context.save()
        let firstID = try #require(LedgerOperations.identifier(for: first))
        let secondID = try #require(LedgerOperations.identifier(for: second))
        let large = Decimal(sign: .plus, exponent: 40, significand: 1)
        let left = try makeItem(context: context, owner: firstID, income: large)
        let right = try makeItem(context: context, owner: secondID, income: 1)
        try context.save()
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try TagMutationOperations.resolveDuplicatesAndSave(context: context, tags: [first])
        }
        #expect(left.ledgerIdentifier == firstID)
        #expect(right.ledgerIdentifier == secondID)
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 2)
        #expect(!context.hasChanges)
    }
}

private extension LedgerImportIdentityTests {
    func exportedContents(_ context: ModelContext) throws -> IncomesFileContents {
        try ItemImportOperations.read(data: ItemExportOperations.incomesFileData(
            fileItems: ItemExportOperations.fileItems(items: context.fetch(.allLedgerItems())),
            currencyCode: "JPY",
            ledgers: ItemExportOperations.fileLedgers(context: context)
        ))
    }

    func makeItem(context: ModelContext, owner: LedgerIdentifier, income: Decimal) throws -> Item {
        let item = try Item.create(
            context: context,
            values: .init(
                date: Date(timeIntervalSince1970: plannedTimeInterval),
                content: "Planned",
                income: income,
                outgo: 0,
                category: "General",
                priority: 0,
                ledgerIdentifier: owner
            ),
            repeatID: UUID()
        )
        item.modify(balance: income)
        return item
    }
}
