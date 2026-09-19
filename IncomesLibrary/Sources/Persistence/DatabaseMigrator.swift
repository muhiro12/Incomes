import Foundation
import MHPlatformCore
import SwiftData

/// Migrates legacy database files into the shared store location.
public enum DatabaseMigrator {
    /// An ambiguous pair of stores requires explicit recovery, never automatic replacement.
    public enum RelocationError: Error {
        case conflictingStores
    }

    /// Moves a legacy store before any shared-store container is opened.
    /// Propagates failures so startup cannot silently continue with an empty database.
    public static func migrateSQLiteFilesIfNeeded() throws {
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
        if legacyURL.standardizedFileURL != currentURL.standardizedFileURL,
           fileManager.fileExists(atPath: legacyURL.path),
           fileManager.fileExists(atPath: currentURL.path) {
            throw RelocationError.conflictingStores
        }
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
        _ = try ModelContainerFactory.make(
            configuration: .init(
                url: currentStoreURL,
                cloudKitDatabase: .none
            )
        )
    }
}
