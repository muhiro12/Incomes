#if DEBUG
import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct DevelopmentStoreSeedingTests {
    @Test(arguments: [
        (SampleDataOperations.Profile.standard, 217),
        (.duplicateTags, 217),
        (.largeLedger, 1_081)
    ])
    func manualInsertionWorksAfterOptingOutWithoutReopening(
        profile: SampleDataOperations.Profile,
        expectedCount: Int
    ) throws {
        let url = try developmentURL()
        let container = try DevelopmentStore.makeContainer(at: url, automaticallySeedsSampleData: false)
        let context = container.mainContext
        #expect(try ItemQueryOperations.allItemsCount(context: context) == .zero)

        try DevelopmentStore.seedIfEmpty(context: context, profile: profile, at: url)

        #expect(try ItemQueryOperations.allItemsCount(context: context) == expectedCount)
        let reopened = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        #expect(try ItemQueryOperations.allItemsCount(context: reopened.mainContext) == expectedCount)
    }

    @Test
    func manualInsertionWorksAfterClearingWithoutReopening() throws {
        let url = try developmentURL()
        let container = try DevelopmentStore.makeContainer(at: url, automaticallySeedsSampleData: true)
        let context = container.mainContext
        try DataMaintenanceOperations.deleteAllDataAndSave(context: context)

        try DevelopmentStore.seedIfEmpty(context: context, profile: .minimal, at: url)

        #expect(try ItemQueryOperations.allItemsCount(context: context) == 3)
    }

    @Test
    func repeatedInsertionPreservesExistingItemsAndIdentities() throws {
        let url = try developmentURL()
        let container = try DevelopmentStore.makeContainer(at: url, automaticallySeedsSampleData: false)
        let context = container.mainContext
        try DevelopmentStore.seedIfEmpty(context: context, profile: .minimal, at: url)
        let items = try context.fetch(.allLedgerItems())
        let item = try #require(items.first)
        item.modify(balance: 123)
        try context.save()
        let values = ItemExportOperations.fileItems(items: items)
        let identifiers = try Set(items.map { try PersistentIdentifierCoder.encode($0.id) })

        #expect(throws: DevelopmentStoreError.containsItems) {
            try DevelopmentStore.seedIfEmpty(context: context, profile: .largeLedger, at: url)
        }

        let reopened = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        let savedItems = try reopened.mainContext.fetch(.allLedgerItems())
        #expect(ItemExportOperations.fileItems(items: savedItems) == values)
        #expect(try Set(savedItems.map { try PersistentIdentifierCoder.encode($0.id) }) == identifiers)
    }

    @Test(arguments: ["Incomes.sqlite", "Incomes-Development.sqlite"])
    func publicEntryRejectsOtherStoreLocationsWithoutMutation(fileName: String) throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        let url = directory.appendingPathComponent(fileName)
        let container = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        try SampleDataOperations.seedAndSave(context: container.mainContext, profile: .minimal)
        let values = ItemExportOperations.fileItems(items: try container.mainContext.fetch(.allLedgerItems()))

        #expect(throws: DevelopmentStoreError.invalidSampleDataTarget) {
            try DevelopmentStore.seedIfEmpty(context: container.mainContext, profile: .standard)
        }

        #expect(!container.mainContext.hasChanges)
        let reopened = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        #expect(ItemExportOperations.fileItems(items: try reopened.mainContext.fetch(.allLedgerItems())) == values)
    }

    @Test
    func rejectsSyncedReadOnlyTransientAndAmbiguousConfigurations() throws {
        let url = try developmentURL()
        let local = ModelConfiguration(url: url, cloudKitDatabase: .none)
        let synced = ModelConfiguration(
            url: url,
            cloudKitDatabase: .private("iCloud.com.example.DevelopmentStoreTests")
        )
        #expect(synced.cloudKitContainerIdentifier != nil)
        let invalidConfigurations: [Set<ModelConfiguration>] = [
            [],
            [synced],
            [.init(url: url, allowsSave: false, cloudKitDatabase: .none)],
            [.init(isStoredInMemoryOnly: true, cloudKitDatabase: .none)],
            [local, .init(url: url.appendingPathExtension("other"), cloudKitDatabase: .none)]
        ]
        for configurations in invalidConfigurations {
            #expect(throws: DevelopmentStoreError.invalidSampleDataTarget) {
                try DevelopmentStore.validateSampleDataTarget(configurations, at: url)
            }
        }
    }

    @Test
    func unsavedChangesAreNeitherCommittedNorDiscarded() throws {
        let url = try developmentURL()
        let container = try DevelopmentStore.makeContainer(at: url, automaticallySeedsSampleData: false)
        let context = container.mainContext
        context.autosaveEnabled = false
        let tag = Tag.createIgnoringDuplicates(context: context, name: "Unfinished edit", type: .category)

        #expect(throws: ItemMutationError.pendingChanges) {
            try DevelopmentStore.seedIfEmpty(context: context, profile: .standard, at: url)
        }

        #expect(context.hasChanges)
        #expect(tag.name == "Unfinished edit")
        #expect(try ItemQueryOperations.allItemsCount(context: context) == .zero)
        let reopened = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        #expect(try reopened.mainContext.fetchCount(.tags(.all)) == .zero)
    }

    private func developmentURL() throws -> URL {
        try persistentTestDirectory(fileManager: .default).appendingPathComponent("Incomes-Development.sqlite")
    }
}
#endif
