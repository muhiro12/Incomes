import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing
/// Relocates a store written by the released 5.x baseline, not a reconstruction.
@MainActor
struct ReleasedStoreRelocationTests {
    private let fixtureDirectory = "Fixtures/ReleasedStore-5.12"
    private let expectedItemCount = 3
    private let expectedOutgoValues = [Decimal(0), Decimal(1), Decimal(2)]

    @Test("A released-version store keeps its records through relocation")
    func released_store_survives_relocation() throws {
        let fileManager: FileManager = .default
        let baseDirectory = try persistentTestDirectory(fileManager: fileManager)
        let legacyDirectory = baseDirectory.appendingPathComponent("legacy", isDirectory: true)
        let currentDirectory = baseDirectory.appendingPathComponent("current", isDirectory: true)
        try fileManager.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: currentDirectory, withIntermediateDirectories: true)
        try copyFixture(into: legacyDirectory)

        let legacyURL = legacyDirectory.appendingPathComponent(Database.fileName)
        let currentURL = currentDirectory.appendingPathComponent(Database.fileName)
        try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: legacyURL,
            currentURL: currentURL
        )

        try verifyRelocatedStore(at: currentURL)
        #expect(!fileManager.fileExists(atPath: legacyURL.path))
    }
}

private extension ReleasedStoreRelocationTests {
    func copyFixture(into directory: URL) throws {
        for suffix in ["", "-wal", "-shm"] {
            let name = Database.fileName + suffix
            let source = try #require(
                Bundle.module.url(
                    forResource: name,
                    withExtension: nil,
                    subdirectory: fixtureDirectory
                )
            )
            try FileManager.default.copyItem(
                at: source,
                to: directory.appendingPathComponent(name)
            )
        }
    }

    func verifyRelocatedStore(at storeURL: URL) throws {
        let container = try ModelContainerFactory.make(
            configuration: .init(url: storeURL, cloudKitDatabase: .none)
        )
        let items = try container.mainContext
            .fetch(FetchDescriptor<Item>())
            .sorted { left, right in
                left.content < right.content
            }

        #expect(items.count == expectedItemCount)
        #expect(items.map(\.content) == ["Salary 0", "Salary 1", "Salary 2"])
        #expect(items.allSatisfy { item in
            item.income == Decimal(string: "1234.56")
        })
        #expect(items.map(\.outgo) == expectedOutgoValues)
        #expect(Set(items.map(\.repeatID)).count == 1)
        #expect(items.allSatisfy { item in
            !(item.tags ?? []).isEmpty
        })
        #expect(items.allSatisfy { item in
            !item.balance.isNaN
        })
    }
}
