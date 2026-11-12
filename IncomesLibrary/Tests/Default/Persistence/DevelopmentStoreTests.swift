#if DEBUG
import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct DevelopmentStoreTests {
    @Test
    func firstLaunchSeedsPersistentLocalStore() throws {
        try withStore { url in
            let container = try open(url)
            #expect(try ItemQueryOperations.allItemsCount(context: container.mainContext) == 217)
            #expect(container.configurations.allSatisfy { configuration in
                configuration.cloudKitContainerIdentifier == nil && !configuration.isStoredInMemoryOnly
            })
            #expect(FileManager.default.fileExists(atPath: url.path))
        }
    }

    @Test
    func reopeningPreservesDeveloperEditsWithoutAddingSamples() throws {
        try withStore { url in
            let identifier = try autoreleasepool {
                let container = try open(url)
                let item = try #require(container.mainContext.fetch(.allLedgerItems()).first)
                item.modify(balance: 123)
                try container.mainContext.save()
                return try PersistentIdentifierCoder.encode(item.persistentModelID)
            }
            let reopened = try open(url)
            #expect(try ItemQueryOperations.allItemsCount(context: reopened.mainContext) == 217)
            let edited = try #require(reopened.mainContext.fetch(.allLedgerItems()).first { item in
                try PersistentIdentifierCoder.encode(item.persistentModelID) == identifier
            })
            #expect(edited.balance == 123)
        }
    }

    @Test
    func intentionallyClearedStoreStaysEmpty() throws {
        try withStore { url in
            try autoreleasepool {
                let container = try open(url)
                try DataMaintenanceOperations.deleteAllDataAndSave(context: container.mainContext)
            }
            let reopened = try open(url)
            #expect(try ItemQueryOperations.allItemsCount(context: reopened.mainContext) == .zero)
        }
    }

    @Test
    func disabledFirstLaunchStaysEmptyWhenSeedingIsEnabledLater() throws {
        try withStore { url in
            try autoreleasepool {
                let container = try open(url, seeds: false)
                #expect(try ItemQueryOperations.allItemsCount(context: container.mainContext) == .zero)
            }
            let reopened = try open(url)
            #expect(try ItemQueryOperations.allItemsCount(context: reopened.mainContext) == .zero)
        }
    }

    @Test
    func disablingSeedingPreservesExistingRecords() throws {
        try withStore { url in
            try autoreleasepool {
                _ = try open(url)
            }
            let reopened = try open(url, seeds: false)
            #expect(try ItemQueryOperations.allItemsCount(context: reopened.mainContext) == 217)
        }
    }

    @Test
    func developmentStoreLeavesReleasedStoreFilesUntouched() throws {
        try withStore { url in
            let releasedURL = url.deletingLastPathComponent().appendingPathComponent(Database.fileName)
            let releasedBytes = Data("released store sentinel".utf8)
            try releasedBytes.write(to: releasedURL)
            _ = try open(url)
            #expect(try Data(contentsOf: releasedURL) == releasedBytes)
            #expect(Database.url.lastPathComponent == "Incomes-Development.sqlite")
            #expect(Database.legacyURL.lastPathComponent == "Incomes.sqlite")
        }
    }

    @Test
    func unreadableExistingStoreFailsWithoutReplacingIt() throws {
        try withStore { url in
            let invalidBytes = Data("invalid development store".utf8)
            try invalidBytes.write(to: url)
            #expect(throws: (any Error).self) {
                _ = try open(url)
            }
            #expect(try Data(contentsOf: url) == invalidBytes)
        }
    }

    private func open(_ url: URL, seeds: Bool = true) throws -> ModelContainer {
        try DevelopmentStore.makeContainer(
            at: url,
            automaticallySeedsSampleData: seeds,
            baseDate: .init(timeIntervalSince1970: 946_728_000),
            locale: .init(identifier: "en_US")
        )
    }

    private func withStore(_ body: (URL) throws -> Void) throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        try body(directory.appendingPathComponent("Incomes-Development.sqlite"))
    }
}
#endif
