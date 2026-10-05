import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

/// Covers interruption, retry, and failure recovery for legacy store relocation.
@MainActor
struct DatabaseMigratorRecoveryTests {
    private let expectedItemCount = 3
    private let secondsPerDay: Double = 86_400

    @Test("Relocating a seeded store preserves its records, amounts, and relationships")
    func relocation_preserves_records() throws {
        try withSandbox { sandbox in
            let seeded = try seedStore(at: sandbox.legacyURL)

            try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
                fileManager: .default,
                legacyURL: sandbox.legacyURL,
                currentURL: sandbox.currentURL
            )

            let relocated = try storeContents(at: sandbox.currentURL)
            #expect(relocated == seeded)
            #expect(!FileManager.default.fileExists(atPath: sandbox.legacyURL.path))
        }
    }

    @Test("Repeating relocation after a completed move changes nothing")
    func repeated_relocation_is_idempotent() throws {
        try withSandbox { sandbox in
            let seeded = try seedStore(at: sandbox.legacyURL)

            for _ in 0..<2 {
                try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
                    fileManager: .default,
                    legacyURL: sandbox.legacyURL,
                    currentURL: sandbox.currentURL
                )
            }

            #expect(try storeContents(at: sandbox.currentURL) == seeded)
        }
    }

    @Test("An interrupted move that left both stores preserves the legacy records")
    func interrupted_move_preserves_legacy_records() throws {
        try withSandbox { sandbox in
            let seeded = try seedStore(at: sandbox.legacyURL)
            // A copy that never reached cleanup leaves a partial destination.
            try Data("partial".utf8).write(to: sandbox.currentURL)

            #expect(throws: DatabaseMigrator.RelocationError.conflictingStores) {
                try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
                    fileManager: .default,
                    legacyURL: sandbox.legacyURL,
                    currentURL: sandbox.currentURL
                )
            }

            #expect(try storeContents(at: sandbox.legacyURL) == seeded)
            #expect(try Data(contentsOf: sandbox.currentURL) == Data("partial".utf8))
        }
    }

    @Test("A destination that cannot be written keeps the legacy store readable")
    func unwritable_destination_keeps_legacy_store() throws {
        try withSandbox { sandbox in
            let seeded = try seedStore(at: sandbox.legacyURL)
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o500],
                ofItemAtPath: sandbox.currentDirectory.path
            )
            defer {
                try? FileManager.default.setAttributes(
                    [.posixPermissions: 0o700],
                    ofItemAtPath: sandbox.currentDirectory.path
                )
            }

            #expect(throws: (any Error).self) {
                try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
                    fileManager: .default,
                    legacyURL: sandbox.legacyURL,
                    currentURL: sandbox.currentURL
                )
            }

            #expect(try storeContents(at: sandbox.legacyURL) == seeded)
        }
    }

    @Test("Relocation retried after a validation failure still moves the records")
    func retry_after_validation_failure_succeeds() throws {
        try withSandbox { sandbox in
            let seeded = try seedStore(at: sandbox.legacyURL)

            #expect(throws: (any Error).self) {
                try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
                    fileManager: .default,
                    legacyURL: sandbox.legacyURL,
                    currentURL: sandbox.currentURL
                ) { _, _ in
                    throw CocoaError(.fileReadCorruptFile)
                }
            }
            #expect(try storeContents(at: sandbox.legacyURL) == seeded)

            try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
                fileManager: .default,
                legacyURL: sandbox.legacyURL,
                currentURL: sandbox.currentURL
            )
            #expect(try storeContents(at: sandbox.currentURL) == seeded)
        }
    }
}

private extension DatabaseMigratorRecoveryTests {
    struct Sandbox {
        let baseDirectory: URL
        let legacyDirectory: URL
        let currentDirectory: URL

        var legacyURL: URL {
            legacyDirectory.appendingPathComponent(Database.fileName)
        }

        var currentURL: URL {
            currentDirectory.appendingPathComponent(Database.fileName)
        }
    }

    struct StoredItem: Equatable {
        let content: String
        let income: Decimal
        let outgo: Decimal
        let balance: Decimal
        let repeatID: UUID
        let tagNames: [String]
    }

    func withSandbox(_ body: (Sandbox) throws -> Void) throws {
        let fileManager: FileManager = .default
        let baseDirectory = try persistentTestDirectory(fileManager: fileManager)
        let legacyDirectory = baseDirectory.appendingPathComponent("legacy", isDirectory: true)
        let currentDirectory = baseDirectory.appendingPathComponent("current", isDirectory: true)
        try fileManager.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: currentDirectory, withIntermediateDirectories: true)
        defer {
            try? fileManager.setAttributes(
                [.posixPermissions: 0o700],
                ofItemAtPath: currentDirectory.path
            )
            try? fileManager.removeItem(at: baseDirectory)
        }
        try body(
            .init(
                baseDirectory: baseDirectory,
                legacyDirectory: legacyDirectory,
                currentDirectory: currentDirectory
            )
        )
    }

    func seedStore(at storeURL: URL) throws -> [StoredItem] {
        let container = try ModelContainerFactory.make(
            configuration: .init(url: storeURL, cloudKitDatabase: .none)
        )
        let context = container.mainContext
        let repeatID = UUID()
        for offset in 0..<expectedItemCount {
            _ = try Item.create(
                context: context,
                values: .init(
                    date: Date(timeIntervalSinceReferenceDate: Double(offset) * secondsPerDay),
                    content: "Salary \(offset)",
                    income: Decimal(string: "1234.56") ?? .zero,
                    outgo: Decimal(offset),
                    category: "Work",
                    priority: .zero
                ),
                repeatID: repeatID
            )
        }
        try BalanceCalculator.calculate(in: context, after: .distantPast)
        try context.save()
        return try storeContents(at: storeURL)
    }

    func storeContents(at storeURL: URL) throws -> [StoredItem] {
        let container = try ModelContainerFactory.make(
            configuration: .init(url: storeURL, cloudKitDatabase: .none)
        )
        return try container.mainContext
            .fetch(FetchDescriptor<Item>())
            .map { item in
                .init(
                    content: item.content,
                    income: item.income,
                    outgo: item.outgo,
                    balance: item.balance,
                    repeatID: item.repeatID,
                    tagNames: (item.tags ?? []).map(\.name).sorted()
                )
            }
            .sorted { left, right in
                left.content < right.content
            }
    }
}
