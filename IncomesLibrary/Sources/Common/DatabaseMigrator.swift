import Foundation
import MHPlatformCore
import SwiftData

/// Migrates legacy database files into the shared store location.
public enum DatabaseMigrator {
    /// Moves the legacy SQLite store into the current location when required.
    public static func migrateSQLiteFilesIfNeeded() {
        do {
            try migrateSQLiteFilesIfNeeded(
                fileManager: .default,
                legacyURL: Database.legacyURL,
                currentURL: Database.url
            )
        } catch {
            assertionFailure("Store migration failed: \(error.localizedDescription)")
        }
    }

    static func migrateSQLiteFilesIfNeeded(
        fileManager: FileManager,
        legacyURL: URL,
        currentURL: URL,
        validateMigration: @Sendable (
            _ currentStoreURL: URL,
            _ copiedFileNames: [String]
        ) throws -> Void = validateMigratedStore
    ) throws {
        guard fileManager.fileExists(atPath: legacyURL.path),
              fileManager.fileExists(atPath: currentURL.path) == false else {
            return
        }

        let filePairs = existingStoreFilePairs(
            fileManager: fileManager,
            legacyURL: legacyURL,
            currentURL: currentURL
        )

        try fileManager.createDirectory(
            at: currentURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try copyStoreFiles(
            filePairs: filePairs,
            fileManager: fileManager
        )

        do {
            try validateMigration(
                currentURL,
                filePairs.map(\.currentURL.lastPathComponent)
            )
        } catch {
            try rollbackCopiedStoreFiles(
                filePairs: filePairs,
                fileManager: fileManager
            )
            throw error
        }

        try removeLegacyStoreFiles(
            filePairs: filePairs,
            fileManager: fileManager
        )
    }
}

private extension DatabaseMigrator {
    struct StoreFilePair {
        let legacyURL: URL
        let currentURL: URL
    }

    static func validateMigratedStore(
        currentStoreURL: URL,
        copiedFileNames _: [String]
    ) throws {
        _ = try ModelContainer(
            for: Item.self,
            configurations: .init(
                url: currentStoreURL,
                cloudKitDatabase: .none
            )
        )
    }

    static func existingStoreFilePairs(
        fileManager: FileManager,
        legacyURL: URL,
        currentURL: URL
    ) -> [StoreFilePair] {
        storeFilePairs(
            legacyURL: legacyURL,
            currentURL: currentURL
        ).filter { pair in
            fileManager.fileExists(atPath: pair.legacyURL.path)
        }
    }

    static func storeFilePairs(
        legacyURL: URL,
        currentURL: URL
    ) -> [StoreFilePair] {
        [legacyURL, legacyShmURL(for: legacyURL), legacyWalURL(for: legacyURL)]
            .enumerated()
            .map { index, legacyFileURL in
                let currentFileURL: URL

                switch index {
                case 0:
                    currentFileURL = currentURL
                case 1:
                    currentFileURL = legacyShmURL(for: currentURL)
                default:
                    currentFileURL = legacyWalURL(for: currentURL)
                }

                return .init(
                    legacyURL: legacyFileURL,
                    currentURL: currentFileURL
                )
            }
    }

    static func copyStoreFiles(
        filePairs: [StoreFilePair],
        fileManager: FileManager
    ) throws {
        for filePair in filePairs {
            try fileManager.copyItem(
                at: filePair.legacyURL,
                to: filePair.currentURL
            )
        }
    }

    static func rollbackCopiedStoreFiles(
        filePairs: [StoreFilePair],
        fileManager: FileManager
    ) throws {
        for filePair in filePairs where fileManager.fileExists(atPath: filePair.currentURL.path) {
            try fileManager.removeItem(at: filePair.currentURL)
        }
    }

    static func removeLegacyStoreFiles(
        filePairs: [StoreFilePair],
        fileManager: FileManager
    ) throws {
        for filePair in filePairs where fileManager.fileExists(atPath: filePair.legacyURL.path) {
            try fileManager.removeItem(at: filePair.legacyURL)
        }
    }

    static func legacyShmURL(
        for storeURL: URL
    ) -> URL {
        storeURL.deletingLastPathComponent().appendingPathComponent(
            "\(storeURL.lastPathComponent)-shm"
        )
    }

    static func legacyWalURL(
        for storeURL: URL
    ) -> URL {
        storeURL.deletingLastPathComponent().appendingPathComponent(
            "\(storeURL.lastPathComponent)-wal"
        )
    }
}
