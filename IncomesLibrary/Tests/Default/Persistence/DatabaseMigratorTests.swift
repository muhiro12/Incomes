//
//  DatabaseMigratorTests.swift
//  IncomesLibraryTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct DatabaseMigratorTests {
    private enum ValidationError: Error {
        case failed
    }

    @Test
    func migrateSQLiteFilesIfNeeded_moves_legacy_files_when_current_missing() throws {
        let fileManager: FileManager = .default
        let sandbox = try makeSandbox(fileManager: fileManager)

        defer {
            try? fileManager.removeItem(at: sandbox.baseDirectory)
        }

        #expect(fileManager.createFile(atPath: sandbox.legacyURL.path, contents: Data()))
        #expect(fileManager.createFile(atPath: sandbox.legacyShmURL.path, contents: Data()))
        #expect(fileManager.createFile(atPath: sandbox.legacyWalURL.path, contents: Data()))

        try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: sandbox.legacyURL,
            currentURL: sandbox.currentURL,
            validateMigration: noOpValidation
        )

        #expect(fileManager.fileExists(atPath: sandbox.currentURL.path))
        #expect(fileManager.fileExists(atPath: sandbox.currentShmURL.path))
        #expect(fileManager.fileExists(atPath: sandbox.currentWalURL.path))
    }

    @Test
    func migrateSQLiteFilesIfNeeded_overwrites_current_files_and_removes_stale_sidecars() throws {
        let fileManager: FileManager = .default
        let sandbox = try makeSandbox(fileManager: fileManager)
        let legacyData = Data("legacy".utf8)
        let staleData = Data("stale".utf8)

        defer {
            try? fileManager.removeItem(at: sandbox.baseDirectory)
        }

        #expect(fileManager.createFile(atPath: sandbox.legacyURL.path, contents: legacyData))
        #expect(fileManager.createFile(atPath: sandbox.legacyWalURL.path, contents: legacyData))
        #expect(fileManager.createFile(atPath: sandbox.currentURL.path, contents: staleData))
        #expect(fileManager.createFile(atPath: sandbox.currentWalURL.path, contents: staleData))
        #expect(fileManager.createFile(atPath: sandbox.currentShmURL.path, contents: staleData))

        try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: sandbox.legacyURL,
            currentURL: sandbox.currentURL,
            validateMigration: noOpValidation
        )

        #expect(try Data(contentsOf: sandbox.currentURL) == legacyData)
        #expect(try Data(contentsOf: sandbox.currentWalURL) == legacyData)
        #expect(!fileManager.fileExists(atPath: sandbox.currentShmURL.path))
        #expect(!fileManager.fileExists(atPath: sandbox.legacyURL.path))
        #expect(!fileManager.fileExists(atPath: sandbox.legacyWalURL.path))
    }

    @Test
    func migrateSQLiteFilesIfNeeded_removes_legacy_files_after_successful_copy() throws {
        let fileManager: FileManager = .default
        let sandbox = try makeSandbox(fileManager: fileManager)

        defer {
            try? fileManager.removeItem(at: sandbox.baseDirectory)
        }

        #expect(fileManager.createFile(atPath: sandbox.legacyURL.path, contents: Data()))
        #expect(fileManager.createFile(atPath: sandbox.legacyShmURL.path, contents: Data()))
        #expect(fileManager.createFile(atPath: sandbox.legacyWalURL.path, contents: Data()))

        try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: sandbox.legacyURL,
            currentURL: sandbox.currentURL,
            validateMigration: noOpValidation
        )

        #expect(fileManager.fileExists(atPath: sandbox.currentURL.path))
        #expect(!fileManager.fileExists(atPath: sandbox.legacyURL.path))
        #expect(!fileManager.fileExists(atPath: sandbox.legacyShmURL.path))
        #expect(!fileManager.fileExists(atPath: sandbox.legacyWalURL.path))
    }

    @Test
    func migrateSQLiteFilesIfNeeded_rolls_back_current_files_when_validation_fails() throws {
        let fileManager: FileManager = .default
        let sandbox = try makeSandbox(fileManager: fileManager)

        defer {
            try? fileManager.removeItem(at: sandbox.baseDirectory)
        }

        #expect(fileManager.createFile(atPath: sandbox.legacyURL.path, contents: Data()))
        #expect(fileManager.createFile(atPath: sandbox.legacyWalURL.path, contents: Data()))

        #expect(throws: ValidationError.failed) {
            try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
                fileManager: fileManager,
                legacyURL: sandbox.legacyURL,
                currentURL: sandbox.currentURL
            ) { _, _ in
                throw ValidationError.failed
            }
        }

        #expect(fileManager.fileExists(atPath: sandbox.legacyURL.path))
        #expect(fileManager.fileExists(atPath: sandbox.legacyWalURL.path))
        #expect(!fileManager.fileExists(atPath: sandbox.currentURL.path))
        #expect(!fileManager.fileExists(atPath: sandbox.currentWalURL.path))
    }

    @Test
    func migrateSQLiteFilesIfNeeded_skips_when_legacy_store_is_missing() throws {
        let fileManager: FileManager = .default
        let sandbox = try makeSandbox(fileManager: fileManager)
        let currentData = Data("current".utf8)

        defer {
            try? fileManager.removeItem(at: sandbox.baseDirectory)
        }

        #expect(fileManager.createFile(atPath: sandbox.currentURL.path, contents: currentData))
        #expect(fileManager.createFile(atPath: sandbox.currentShmURL.path, contents: currentData))
        #expect(fileManager.createFile(atPath: sandbox.currentWalURL.path, contents: currentData))

        try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: sandbox.legacyURL,
            currentURL: sandbox.currentURL,
            validateMigration: noOpValidation
        )

        #expect(try Data(contentsOf: sandbox.currentURL) == currentData)
        #expect(try Data(contentsOf: sandbox.currentShmURL) == currentData)
        #expect(try Data(contentsOf: sandbox.currentWalURL) == currentData)
    }

    @Test
    func migrateSQLiteFilesIfNeeded_skips_when_store_locations_match() throws {
        let fileManager: FileManager = .default
        let sandbox = try makeSandbox(fileManager: fileManager)
        let legacyData = Data("legacy".utf8)

        defer {
            try? fileManager.removeItem(at: sandbox.baseDirectory)
        }

        #expect(fileManager.createFile(atPath: sandbox.legacyURL.path, contents: legacyData))
        #expect(fileManager.createFile(atPath: sandbox.legacyWalURL.path, contents: legacyData))

        try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: sandbox.legacyURL,
            currentURL: sandbox.legacyURL,
            validateMigration: noOpValidation
        )

        #expect(try Data(contentsOf: sandbox.legacyURL) == legacyData)
        #expect(try Data(contentsOf: sandbox.legacyWalURL) == legacyData)
    }

    @Test
    @MainActor
    func migrateSQLiteFilesIfNeeded_validates_copied_swiftdata_store() throws {
        let fileManager: FileManager = .default
        let sandbox = try makeSandbox(fileManager: fileManager)

        defer {
            try? fileManager.removeItem(at: sandbox.baseDirectory)
        }

        try seedStore(at: sandbox.legacyURL)

        try DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: sandbox.legacyURL,
            currentURL: sandbox.currentURL
        )

        let currentContainer = try ModelContainer(
            for: Item.self,
            configurations: .init(
                url: sandbox.currentURL,
                cloudKitDatabase: .none
            )
        )
        let currentItems = try currentContainer.mainContext.fetch(
            FetchDescriptor<Item>()
        )

        #expect(currentItems.count == 1)
        #expect(currentItems.first?.content == "Salary")
        #expect(!fileManager.fileExists(atPath: sandbox.legacyURL.path))
    }
}

private extension DatabaseMigratorTests {
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

        var legacyShmURL: URL {
            legacyDirectory.appendingPathComponent("\(Database.fileName)-shm")
        }

        var currentShmURL: URL {
            currentDirectory.appendingPathComponent("\(Database.fileName)-shm")
        }

        var legacyWalURL: URL {
            legacyDirectory.appendingPathComponent("\(Database.fileName)-wal")
        }

        var currentWalURL: URL {
            currentDirectory.appendingPathComponent("\(Database.fileName)-wal")
        }
    }

    func makeSandbox(
        fileManager: FileManager
    ) throws -> Sandbox {
        let baseDirectory = fileManager.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        let legacyDirectory = baseDirectory.appendingPathComponent("legacy", isDirectory: true)
        let currentDirectory = baseDirectory.appendingPathComponent("current", isDirectory: true)

        try fileManager.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: currentDirectory, withIntermediateDirectories: true)

        return .init(
            baseDirectory: baseDirectory,
            legacyDirectory: legacyDirectory,
            currentDirectory: currentDirectory
        )
    }

    func noOpValidation(
        currentStoreURL _: URL,
        copiedFileNames _: [String]
    ) {
        // no-op
    }

    @MainActor
    func seedStore(
        at storeURL: URL
    ) throws {
        let legacyContainer = try ModelContainer(
            for: Item.self,
            configurations: .init(
                url: storeURL,
                cloudKitDatabase: .none
            )
        )
        let legacyContext = legacyContainer.mainContext
        _ = try Item.create(
            context: legacyContext,
            values: .init(
                date: .now,
                content: "Salary",
                income: 100,
                outgo: .zero,
                category: "Work",
                priority: .zero
            ),
            repeatID: UUID()
        )
        try legacyContext.save()
    }
}
