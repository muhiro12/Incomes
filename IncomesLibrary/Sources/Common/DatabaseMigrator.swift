import Foundation
import MHPersistenceMaintenance

/// Documented for SwiftLint compliance.
public enum DatabaseMigrator {
    /// Documented for SwiftLint compliance.
    public static func migrateSQLiteFilesIfNeeded() {
        migrateSQLiteFilesIfNeeded(
            fileManager: .default,
            legacyURL: Database.legacyURL,
            currentURL: Database.url
        )
    }

    static func migrateSQLiteFilesIfNeeded(
        fileManager: FileManager,
        legacyURL: URL,
        currentURL: URL
    ) {
        guard fileManager.fileExists(atPath: legacyURL.path),
              fileManager.fileExists(atPath: currentURL.path) == false else {
            return
        }

        do {
            let plan = MHStoreMigrationPlan(
                legacyStoreURL: legacyURL,
                currentStoreURL: currentURL
            )

            let outcome = try MHStoreMigrator.migrateIfNeeded(
                plan: plan,
                fileManager: fileManager
            )
            if case .migrated = outcome {
                _ = try MHStoreMigrator.removeLegacyStoreFilesIfNeeded(
                    plan: plan,
                    fileManager: fileManager
                )
            }
        } catch {
            assertionFailure("Store migration failed: \(error.localizedDescription)")
        }
    }
}
