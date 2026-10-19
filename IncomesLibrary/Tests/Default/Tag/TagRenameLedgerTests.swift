import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct TagRenameLedgerTests {
    private let incomeAmount: Decimal = 10

    @Test(arguments: [false, true])
    func aSharedCategoryRenameReturnsTheSavedDestination(autosaveEnabled: Bool) throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        let url = directory.appendingPathComponent("test.store")
        let container = try ModelContainerFactory.make(
            configuration: .init(url: url, cloudKitDatabase: .none)
        )
        let context = ModelContext(container)
        let fixture = try sharedCategory(context: context)
        context.autosaveEnabled = autosaveEnabled
        let renamed = try TagRenameOperations.renameCategoryAndSave(
            context: context,
            tag: fixture.tag,
            to: "Travel"
        )
        let encodedID = try PersistentIdentifierCoder.encode(renamed.persistentModelID)
        #expect(renamed.name == "Travel")
        #expect(renamed.id != fixture.tag.id)
        #expect(fixture.tag.name == "Food")
        #expect(!context.hasChanges)
        #expect(context.autosaveEnabled == autosaveEnabled)
        let reader = ModelContext(try ModelContainerFactory.readOnly(at: url))
        let resolved = try #require(try TagQueryOperations.getByID(context: reader, id: encodedID))
        #expect(resolved.name == "Travel")
        #expect(try reader.fetch(.items(.all)).first?.category?.id == resolved.id)
        #expect(try reader.fetch(.items(.all, ledgerIdentifier: fixture.other)).first?.category?.name == "Food")
    }

    @Test
    func renamingPreservesUnrelatedPendingChanges() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let fixture = try sharedCategory(context: context)
        _ = try Tag.create(context: context, name: "Unsaved", type: .content)
        #expect(throws: TagRenameError.pendingChanges) {
            try TagRenameOperations.renameCategoryAndSave(context: context, tag: fixture.tag, to: "Travel")
        }
        #expect(context.hasChanges)
        #expect(fixture.tag.name == "Food")
        #expect(try TagQueryOperations.getByName(context: context, name: "Unsaved", type: .content) != nil)
        #expect(try TagQueryOperations.getByName(context: context, name: "Travel", type: .category) == nil)
    }
}

private extension TagRenameLedgerTests {
    func sharedCategory(context: ModelContext) throws -> (tag: IncomesLibrary.Tag, other: LedgerIdentifier) {
        let other = try LedgerOperations.create(context: context, name: "Other").id
        for owner in [LedgerIdentifier.default, other] {
            _ = try Item.create(
                context: context,
                values: .init(
                    date: .now,
                    content: "Saved",
                    income: incomeAmount,
                    outgo: 0,
                    category: "Food",
                    priority: 0,
                    ledgerIdentifier: owner
                ),
                repeatID: UUID()
            )
        }
        try context.save()
        let tag = try #require(try TagQueryOperations.getByName(context: context, name: "Food", type: .category))
        return (tag, other)
    }
}
