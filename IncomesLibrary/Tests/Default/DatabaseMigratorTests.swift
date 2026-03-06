//
//  DatabaseMigratorTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//

import Foundation
@testable import IncomesLibrary
import Testing

struct DatabaseMigratorTests {
    @Test
    func migrateSQLiteFilesIfNeeded_moves_legacy_files_when_current_missing() throws {
        let fileManager: FileManager = .default
        let baseDirectory = fileManager.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        let legacyDirectory = baseDirectory.appendingPathComponent("legacy", isDirectory: true)
        let currentDirectory = baseDirectory.appendingPathComponent("current", isDirectory: true)

        try fileManager.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: currentDirectory, withIntermediateDirectories: true)

        let legacyURL = legacyDirectory.appendingPathComponent(Database.fileName)
        let currentURL = currentDirectory.appendingPathComponent(Database.fileName)

        defer {
            try? fileManager.removeItem(at: baseDirectory)
        }

        #expect(fileManager.createFile(atPath: legacyURL.path, contents: Data()))
        #expect(fileManager.createFile(atPath: legacyDirectory.appendingPathComponent("\(Database.fileName)-shm").path, contents: Data())) // swiftlint:disable:this line_length
        #expect(fileManager.createFile(atPath: legacyDirectory.appendingPathComponent("\(Database.fileName)-wal").path, contents: Data())) // swiftlint:disable:this line_length

        DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: legacyURL,
            currentURL: currentURL
        )

        #expect(fileManager.fileExists(atPath: currentURL.path))
        #expect(fileManager.fileExists(atPath: currentDirectory.appendingPathComponent("\(Database.fileName)-shm").path)) // swiftlint:disable:this line_length
        #expect(fileManager.fileExists(atPath: currentDirectory.appendingPathComponent("\(Database.fileName)-wal").path)) // swiftlint:disable:this line_length
    }

    @Test
    func migrateSQLiteFilesIfNeeded_does_nothing_when_current_exists() throws {
        let fileManager: FileManager = .default
        let baseDirectory = fileManager.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        let legacyDirectory = baseDirectory.appendingPathComponent("legacy", isDirectory: true)
        let currentDirectory = baseDirectory.appendingPathComponent("current", isDirectory: true)

        try fileManager.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: currentDirectory, withIntermediateDirectories: true)

        let legacyURL = legacyDirectory.appendingPathComponent(Database.fileName)
        let currentURL = currentDirectory.appendingPathComponent(Database.fileName)

        defer {
            try? fileManager.removeItem(at: baseDirectory)
        }

        #expect(fileManager.createFile(atPath: legacyURL.path, contents: Data()))
        #expect(fileManager.createFile(atPath: currentURL.path, contents: Data()))

        DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: legacyURL,
            currentURL: currentURL
        )

        #expect(fileManager.fileExists(atPath: legacyURL.path))
        #expect(fileManager.fileExists(atPath: currentURL.path))
    }

    @Test
    func migrateSQLiteFilesIfNeeded_removes_legacy_files_after_successful_copy() throws {
        let fileManager: FileManager = .default
        let baseDirectory = fileManager.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        let legacyDirectory = baseDirectory.appendingPathComponent("legacy", isDirectory: true)
        let currentDirectory = baseDirectory.appendingPathComponent("current", isDirectory: true)

        try fileManager.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: currentDirectory, withIntermediateDirectories: true)

        let legacyURL = legacyDirectory.appendingPathComponent(Database.fileName)
        let currentURL = currentDirectory.appendingPathComponent(Database.fileName)
        let legacyShmURL = legacyDirectory.appendingPathComponent("\(Database.fileName)-shm")
        let legacyWalURL = legacyDirectory.appendingPathComponent("\(Database.fileName)-wal")

        defer {
            try? fileManager.removeItem(at: baseDirectory)
        }

        #expect(fileManager.createFile(atPath: legacyURL.path, contents: Data()))
        #expect(fileManager.createFile(atPath: legacyShmURL.path, contents: Data()))
        #expect(fileManager.createFile(atPath: legacyWalURL.path, contents: Data()))

        DatabaseMigrator.migrateSQLiteFilesIfNeeded(
            fileManager: fileManager,
            legacyURL: legacyURL,
            currentURL: currentURL
        )

        #expect(fileManager.fileExists(atPath: currentURL.path))
        #expect(!fileManager.fileExists(atPath: legacyURL.path))
        #expect(!fileManager.fileExists(atPath: legacyShmURL.path))
        #expect(!fileManager.fileExists(atPath: legacyWalURL.path))
    }
}
