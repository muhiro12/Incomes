import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct ItemImportPersistenceTests {
    @Test
    func saved_import_reopens_with_exact_values_and_permanent_identifiers() throws {
        try withStore { url in
            let contents = try fixtureContents()
            let createdIDs = try importContents(contents, at: url)
            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            let items = fetchItems(container.mainContext)
            #expect(ItemExportOperations.fileItems(items: items) == contents.items)
            let reopenedIDs = try Set(items.map { item in
                try PersistentIdentifierCoder.encode(item.persistentModelID)
            })
            #expect(reopenedIDs == createdIDs)
            #expect(try ItemImportOperations.difference(
                contents: contents,
                context: container.mainContext
            ).isIdentical)
        }
    }

    @Test
    func pending_edits_are_neither_saved_nor_rolled_back() throws {
        try withStore { url in
            let contents = try fixtureContents()
            _ = try importContents(contents, at: url)
            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            let context = ModelContext(container)
            let difference = try ItemImportOperations.difference(contents: contents, context: context)
            let item = try #require(fetchItems(context).first)
            let savedContent = item.content
            try modifyContent(of: item, to: "Unsaved draft")
            #expect(throws: ItemImportError.storeChangedSinceReview) {
                try ItemImportOperations.applyAndSaveWithOutcome(
                    contents: contents,
                    reviewed: difference,
                    policy: .replace,
                    context: context
                )
            }
            #expect(item.content == "Unsaved draft")
            #expect(context.hasChanges)
            let savedItems = fetchItems(ModelContext(container))
            #expect(savedItems.contains { saved in
                saved.persistentModelID == item.persistentModelID && saved.content == savedContent
            })
        }
    }

    @Test
    func a_saved_change_after_review_refuses_the_import() throws {
        try withStore { url in
            let contents = try fixtureContents()
            _ = try importContents(contents, at: url)
            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            let context = ModelContext(container)
            let difference = try ItemImportOperations.difference(contents: contents, context: context)
            let item = try #require(fetchItems(context).first)
            try item.modify(values: IncomesFileItem(item: item).storedValues, repeatID: UUID())
            try context.save()
            #expect(throws: ItemImportError.storeChangedSinceReview) {
                try ItemImportOperations.applyAndSaveWithOutcome(
                    contents: contents,
                    reviewed: difference,
                    policy: .replace,
                    context: context
                )
            }
            #expect(!context.hasChanges)
        }
    }

    @Test
    func a_real_save_failure_preserves_the_persistent_store() throws {
        try withStore { url in
            let contents = try fixtureContents()
            _ = try importContents(contents, at: url)
            try attemptReadOnlyReplacement(at: url)
            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            #expect(ItemExportOperations.fileItems(items: fetchItems(container.mainContext)) == contents.items)
        }
    }
}

private extension ItemImportPersistenceTests {
    func modifyContent(of item: Item, to content: String) throws {
        try item.modify(
            values: .init(
                date: item.localDate,
                content: content,
                income: item.income,
                outgo: item.outgo,
                category: item.category?.name ?? "",
                priority: item.priority
            ),
            repeatID: item.repeatID
        )
    }

    func withStore(_ body: (URL) throws -> Void) throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try body(directory.appendingPathComponent("Incomes.sqlite"))
    }

    func fixtureContents() throws -> IncomesFileContents {
        let url = try #require(Bundle.module.url(
            forResource: "Incomes",
            withExtension: "incomes",
            subdirectory: "Fixtures/IncomesFile-2.0.0"
        ))
        return try ItemImportOperations.read(data: Data(contentsOf: url))
    }

    func importContents(_ contents: IncomesFileContents, at url: URL) throws -> Set<String> {
        let container = try ModelContainerFactory.make(
            configuration: .init(url: url, cloudKitDatabase: .none)
        )
        let context = ModelContext(container)
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        let mutation = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init()),
            context: context
        )
        #expect(mutation.value.addedCount == contents.items.count)
        #expect(!context.hasChanges)
        return try withExtendedLifetime(container) {
            try Set(mutation.outcome.changedIDs.created.map(PersistentIdentifierCoder.encode))
        }
    }

    func attemptReadOnlyReplacement(at url: URL) throws {
        let container = try ModelContainerFactory.readOnly(at: url)
        let context = ModelContext(container)
        let contents = IncomesFileContents(
            schemaVersion: "2.0.0",
            exportedAt: .now,
            currencyCode: "JPY",
            items: []
        )
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(throws: (any Error).self) {
            try ItemImportOperations.applyAndSaveWithOutcome(
                contents: contents,
                reviewed: difference,
                policy: .replace,
                context: context
            )
        }
        #expect(!context.hasChanges)
        #expect(!fetchItems(context).isEmpty)
    }
}
