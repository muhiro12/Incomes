import Foundation
import MHPlatformCore
import SwiftData

/// Migrates legacy database files into the shared store location.
public enum DatabaseMigrator {
    /// Moves the legacy SQLite store into the current location when required.
    public static func migrateSQLiteFilesIfNeeded() {
        do {
            try migrateSQLiteFilesIfNeededOrThrow()
        } catch {
            assertionFailure("Store migration failed: \(error.localizedDescription)")
        }
    }

    /// Moves the legacy SQLite store and surfaces failures to the caller.
    public static func migrateSQLiteFilesIfNeededOrThrow() throws {
        try migrateSQLiteFilesIfNeeded(
            fileManager: .default,
            legacyURL: Database.legacyURL,
            currentURL: Database.url
        )
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
        let plan = MHStoreRelocationPlan(
            legacyStoreURL: legacyURL,
            currentStoreURL: currentURL
        )

        let outcome = try MHStoreRelocationService.relocateIfNeeded(
            plan: plan,
            fileManager: fileManager,
            validateRelocatedStore: validateMigration
        )
        if case .relocated = outcome {
            _ = try MHStoreRelocationService.removeLegacyStoreFilesIfNeeded(
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
