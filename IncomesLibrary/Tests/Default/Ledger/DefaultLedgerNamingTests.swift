import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct DefaultLedgerNamingTests {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        container = try ModelContainerFactory.inMemory()
        context = .init(container)
    }

    @Test
    func renameAndResetPreserveItemsBalancesAndDefaultIdentity() throws {
        let item = try Item.create(
            context: context,
            values: .init(
                date: .now,
                content: "Salary",
                income: 100,
                outgo: 0,
                category: "Work",
                priority: 0
            ),
            repeatID: UUID()
        )
        item.modify(balance: 900)
        try context.save()
        let itemID = item.persistentModelID
        let ownershipIDs = (item.tags ?? []).filter { $0.type == .defaultLedger }.map(\.id)
        let systemName = try LedgerOperations.ledger(.default, context: context).name

        try LedgerOperations.rename(.default, to: "  Household  ", context: context)
        let renamed = try LedgerOperations.ledger(.default, context: context)
        #expect(renamed.id == .default)
        #expect(renamed.name == "Household")
        #expect(renamed.isNameCustomized)
        #expect(try LedgerOperations.ledgers(context: context).first == renamed)
        #expect(item.ledgerIdentifier == .default)
        #expect(item.persistentModelID == itemID)
        #expect(item.balance == 900)
        #expect((item.tags ?? []).filter { $0.type == .defaultLedger }.map(\.id) == ownershipIDs)
        #expect(ItemExportOperations.fileItems(items: [item]).first?.ledgerIdentifier == .default)
        #expect(try ItemExportOperations.fileLedgers(context: context).isEmpty)

        try LedgerOperations.resetDefaultName(context: context)
        let restored = try LedgerOperations.ledger(.default, context: context)
        #expect(restored.name == systemName)
        #expect(!restored.isNameCustomized)
        #expect(item.ledgerIdentifier == .default && item.balance == 900)
        #expect(item.persistentModelID == itemID)
        #expect(!context.hasChanges)
    }

    @Test
    func emptyDefaultBookCanBeRenamedAndResetWithoutCreatingItems() throws {
        #expect(try context.fetchCount(.tags(.ledgerMetadata)) == 0)
        try LedgerOperations.rename(.default, to: "Personal", context: context)
        #expect(try LedgerOperations.ledger(.default, context: context).name == "Personal")
        #expect(try context.fetchCount(.tags(.ledgerMetadata)) == 1)
        #expect(try context.fetchCount(.allLedgerItems()) == 0)
        try LedgerOperations.resetDefaultName(context: context)
        #expect(try !LedgerOperations.ledger(.default, context: context).isNameCustomized)
        #expect(try context.fetchCount(.tags(.typeIs(.defaultLedger))) == 1)
    }

    @Test
    func legacyNamesStayLocalizedAndExplicitChangesUpdateEveryDefaultTag() throws {
        let legacy = Tag.createIgnoringDuplicates(context: context, name: "Default Ledger", type: .defaultLedger)
        let custom = Tag.createIgnoringDuplicates(context: context, name: "Household", type: .defaultLedger)
        let empty = Tag.createIgnoringDuplicates(context: context, name: "", type: .defaultLedger)
        try context.save()
        let identifiers = Set([legacy.id, custom.id, empty.id])
        #expect(try LedgerOperations.ledger(.default, context: context).name == "Household")
        #expect(try LedgerOperations.ledgers(context: context).count == 1)

        try LedgerOperations.rename(.default, to: "Family", context: context)
        #expect([legacy, custom, empty].allSatisfy { $0.name == "Family" })
        #expect(Set([legacy.id, custom.id, empty.id]) == identifiers)
        try LedgerOperations.resetDefaultName(context: context)
        #expect([legacy, custom, empty].allSatisfy { $0.name == "Default Ledger" })
        #expect(try !LedgerOperations.ledger(.default, context: context).isNameCustomized)
        #expect(try context.fetchCount(.tags(.typeIs(.defaultLedger))) == 3)
        #expect(!context.hasChanges)
    }

    @Test
    func conflictingCustomNamesResolveDeterministicallyWithoutReadWrites() throws {
        _ = Tag.createIgnoringDuplicates(context: context, name: "Zulu", type: .defaultLedger)
        _ = Tag.createIgnoringDuplicates(context: context, name: "Alpha", type: .defaultLedger)
        try context.save()
        #expect(try LedgerOperations.ledger(.default, context: context).name == "Alpha")
        #expect(try LedgerOperations.ledgers(context: context).first?.name == "Alpha")
        #expect(!context.hasChanges)
    }

    @Test
    func namesAreValidatedAcrossDefaultAndAdditionalBooks() throws {
        let additional = try LedgerOperations.create(context: context, name: "Savings")
        #expect(throws: LedgerError.invalidName) {
            try LedgerOperations.rename(.default, to: " \n ", context: context)
        }
        #expect(throws: LedgerError.duplicateName) {
            try LedgerOperations.rename(.default, to: additional.name, context: context)
        }
        try LedgerOperations.rename(.default, to: "Household", context: context)
        #expect(throws: LedgerError.duplicateName) {
            try LedgerOperations.create(context: context, name: "Household")
        }
        #expect(throws: LedgerError.duplicateName) {
            try LedgerOperations.rename(additional.id, to: "Household", context: context)
        }
        #expect(try LedgerOperations.ledger(additional.id, context: context).name == "Savings")
        #expect(!context.hasChanges)
    }

    @Test
    func restoringTheSystemNameRemainsPossibleWithAnExistingSameNameBook() throws {
        let systemName = try LedgerOperations.ledger(.default, context: context).name
        _ = Tag.createIgnoringDuplicates(context: context, name: systemName, type: .ledger)
        try context.save()
        try LedgerOperations.rename(.default, to: "Household", context: context)
        try LedgerOperations.resetDefaultName(context: context)
        #expect(try LedgerOperations.ledger(.default, context: context).name == systemName)
        #expect(try LedgerOperations.ledgers(context: context).count == 2)
    }

    @Test
    func unsavedEditsAreNeitherSavedNorDiscardedByNameChanges() throws {
        try LedgerOperations.rename(.default, to: "Household", context: context)
        _ = Tag.createIgnoringDuplicates(context: context, name: "Draft", type: .category)
        #expect(throws: LedgerError.pendingChanges) {
            try LedgerOperations.rename(.default, to: "Personal", context: context)
        }
        #expect(throws: LedgerError.pendingChanges) {
            try LedgerOperations.resetDefaultName(context: context)
        }
        #expect(try LedgerOperations.ledger(.default, context: context).name == "Household")
        #expect(context.hasChanges)
    }
}
