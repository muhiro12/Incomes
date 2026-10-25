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
    func a_six_zero_import_reopens_with_exact_values_and_resolved_ledger_ownership() throws {
        try withStore { url in
            let contents = try ItemImportOperations.read(data: sixZeroData())
            let createdIDs = try importContents(contents, at: url)
            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            let context = container.mainContext
            let items = try context.fetch(.allLedgerItems())
            #expect(try Set(items.map { item in
                try PersistentIdentifierCoder.encode(item.persistentModelID)
            }) == createdIDs)
            #expect(try ItemImportOperations.difference(contents: contents, context: context).isIdentical)
            let ledgers = try LedgerOperations.ledgers(context: context)
            for source in contents.ledgers {
                let destination = try #require(ledgers.first { $0.name == source.name })
                let expected = contents.items.filter { $0.ledgerIdentifier == source.id }.map { item in
                    item.assigning(to: destination.id)
                }
                let restored = items.filter { $0.ledgerIdentifier == destination.id }.map { item in
                    IncomesFileItem(item: item, balance: item.balance)
                }
                #expect(IncomesFileItem.sortedByValue(restored) == IncomesFileItem.sortedByValue(expected))
            }
            let defaultItems = items.filter { $0.ledgerIdentifier == .default }
            #expect(ItemExportOperations.fileItems(items: defaultItems) == contents.items.filter { item in
                item.ledgerIdentifier == .default
            })
        }
    }

    @Test
    func a_rejected_six_zero_amount_preserves_saved_records_and_identity() throws {
        try withStore { url in
            let contents = try fixtureContents()
            let createdIDs = try importContents(contents, at: url)
            var object = try #require(JSONSerialization.jsonObject(with: sixZeroData()) as? [String: Any])
            var incomingItems = try #require(object["items"] as? [[String: Any]])
            incomingItems[0]["income"] = "invalid amount"
            object["items"] = incomingItems
            let data = try JSONSerialization.data(withJSONObject: object)
            #expect(throws: ItemImportError.invalidItem(index: 0, field: .income)) {
                try ItemImportOperations.read(data: data)
            }
            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            let items = fetchItems(container.mainContext)
            #expect(ItemExportOperations.fileItems(items: items) == contents.items)
            #expect(try Set(items.map { item in
                try PersistentIdentifierCoder.encode(item.persistentModelID)
            }) == createdIDs)
        }
    }

    @Test(arguments: [
        ("fileType", #""com.muhiro12.incomes.data""#, ItemImportError.unrecognizedFormat),
        ("formatVersion", "2", ItemImportError.newerFormatVersion(2)),
        ("schemaVersion", #""3.0.0""#, ItemImportError.newerSchemaVersion("3.0.0"))
    ])
    func refusing_unsupported_files_preserves_saved_records_and_identity(
        key: String,
        json: String,
        error: ItemImportError
    ) throws {
        try withStore { url in
            let contents = try fixtureContents()
            let createdIDs = try importContents(contents, at: url)
            let validData = try ItemExportOperations.incomesFileData(
                fileItems: contents.items,
                currencyCode: contents.currencyCode ?? "",
                exportedAt: contents.exportedAt
            )
            var object = try #require(JSONSerialization.jsonObject(with: validData) as? [String: Any])
            object[key] = try JSONSerialization.jsonObject(with: Data(json.utf8), options: .fragmentsAllowed)
            let rejectedData = try JSONSerialization.data(withJSONObject: object)
            #expect(throws: error) {
                try ItemImportOperations.read(data: rejectedData)
            }

            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            let items = fetchItems(container.mainContext)
            #expect(ItemExportOperations.fileItems(items: items) == contents.items)
            #expect(try Set(items.map { item in
                try PersistentIdentifierCoder.encode(item.persistentModelID)
            }) == createdIDs)
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
            subdirectory: "Fixtures/IncomesFile-1-Schema-2.0.0"
        ))
        return try ItemImportOperations.read(data: Data(contentsOf: url))
    }

    func sixZeroData() throws -> Data {
        let url = try #require(Bundle.module.url(
            forResource: "Incomes-6.0", withExtension: "incomes", subdirectory: "Fixtures"
        ))
        return try Data(contentsOf: url)
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
            formatVersion: 1,
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
