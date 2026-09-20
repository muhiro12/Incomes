import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

/// Upgrades a store written by the released 5.x baseline with the current plan.
@MainActor
struct ReleasedStoreSchemaMigrationTests {
    private let fixtureDirectory = "Fixtures/ReleasedStore-5.12"
    private let expectedItemCount = 3
    private let expectedIncome = Decimal(string: "1234.56") ?? .zero
    private let corruptedHeaderLength = 16
    private let expectedOutgoValues = [Decimal(0), Decimal(1), Decimal(2)]

    @Test("A released store upgrades in place and keeps every invariant")
    func released_store_upgrades_and_keeps_invariants() throws {
        try withFixtureStore { url in
            let identifier = try openAndVerify(at: url)
            // Reopening an already-current store must change nothing.
            let reopenedIdentifier = try openAndVerify(at: url)
            #expect(reopenedIdentifier == identifier)
        }
    }

    @Test("An extension opens the released store read-only after the host upgraded it")
    func extension_reads_released_store_after_host_upgrade() throws {
        try withFixtureStore { url in
            _ = try openAndVerify(at: url)

            let readOnlyContainer = try ModelContainerFactory.readOnly(at: url)
            let items = try readOnlyContainer.mainContext.fetch(FetchDescriptor<Item>())
            #expect(items.count == expectedItemCount)
        }
    }

    @Test("A corrupt store fails to open and is left untouched")
    func corrupt_store_fails_without_reset() throws {
        try withFixtureStore { url in
            let originalSize = try Data(contentsOf: url).count
            var corrupted = try Data(contentsOf: url)
            corrupted.replaceSubrange(
                0..<corruptedHeaderLength,
                with: Data(repeating: .max, count: corruptedHeaderLength)
            )
            try corrupted.write(to: url)

            #expect(throws: (any Error).self) {
                _ = try ModelContainerFactory.make(
                    configuration: .init(url: url, cloudKitDatabase: .none)
                )
            }
            #expect(try Data(contentsOf: url).count == originalSize)
        }
    }
}

private extension ReleasedStoreSchemaMigrationTests {
    func withFixtureStore(_ body: (URL) throws -> Void) throws {
        let fileManager: FileManager = .default
        let directory = fileManager.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? fileManager.removeItem(at: directory)
        }

        for suffix in ["", "-wal", "-shm"] {
            let name = Database.fileName + suffix
            let source = try #require(
                Bundle.module.url(
                    forResource: name,
                    withExtension: nil,
                    subdirectory: fixtureDirectory
                )
            )
            try fileManager.copyItem(
                at: source,
                to: directory.appendingPathComponent(name)
            )
        }

        try body(directory.appendingPathComponent(Database.fileName))
    }

    @discardableResult
    func openAndVerify(at url: URL) throws -> String {
        let container = try ModelContainerFactory.make(
            configuration: .init(url: url, cloudKitDatabase: .none)
        )
        let items = try container.mainContext
            .fetch(FetchDescriptor<Item>())
            .sorted { left, right in
                left.content < right.content
            }

        #expect(items.count == expectedItemCount)
        #expect(items.allSatisfy { item in
            item.income == expectedIncome
        })
        #expect(items.map(\.outgo) == expectedOutgoValues)
        #expect(items.allSatisfy { item in
            item.priority == .zero
        })
        #expect(Set(items.map(\.repeatID)).count == 1)
        #expect(items.allSatisfy { item in
            (item.tags ?? []).contains { tag in
                tag.name == "Work"
            }
        })
        #expect(items.allSatisfy { item in
            !item.balance.isNaN
        })
        #expect(items.map(\.utcDate) == items.map(\.utcDate).sorted())

        let first = try #require(items.first)
        return try PersistentIdentifierCoder.encode(first.persistentModelID)
    }
}
