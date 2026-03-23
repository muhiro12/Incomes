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

        let plan = MHStoreMigrationPlan(
            legacyStoreURL: legacyURL,
            currentStoreURL: currentURL
        )

        let outcome = try MHStoreMigrator.migrateIfNeeded(
            plan: plan,
            fileManager: fileManager,
            validateMigration: validateMigration
        )
        if case .migrated = outcome {
            _ = try MHStoreMigrator.removeLegacyStoreFilesIfNeeded(
                plan: plan,
                fileManager: fileManager
            )
        }
    }
}

private extension DatabaseMigrator {
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
}
