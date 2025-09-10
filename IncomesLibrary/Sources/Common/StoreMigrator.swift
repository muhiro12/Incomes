import Foundation

public enum StoreMigrator {
    /// Migrates a SQLite store and its sidecar files (-wal/-shm) from a legacy location into the shared App Group location.
    /// The operation is idempotent: if the destination main file already exists, migration is skipped.
    public static func migrateSQLiteFilesIfNeeded(from legacyURL: URL, to sharedURL: URL) {
        let fileManager: FileManager = .default

        // Skip if the shared store already exists or the legacy one does not.
        guard !fileManager.fileExists(atPath: sharedURL.path),
              fileManager.fileExists(atPath: legacyURL.path) else {
            return
        }

        do {
            try fileManager.createDirectory(
                at: sharedURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let legacyDir = legacyURL.deletingLastPathComponent()
            let baseName = legacyURL.lastPathComponent // e.g., "Incomes.sqlite"
            // Collect the main file and possible SQLite sidecars in the legacy directory.
            let candidateNames = try fileManager.contentsOfDirectory(atPath: legacyDir.path)
                .filter { $0 == baseName || $0.hasPrefix(baseName + "-") }

            for name in candidateNames {
                let source = legacyDir.appendingPathComponent(name)
                let destination = sharedURL.deletingLastPathComponent().appendingPathComponent(name)
                do {
                    try fileManager.moveItem(at: source, to: destination)
                } catch {
                    // If move fails (e.g. cross-volume), fallback to copy when destination is missing.
                    if !fileManager.fileExists(atPath: destination.path) {
                        try fileManager.copyItem(at: source, to: destination)
                    }
                }
            }
        } catch {
            // Prefer not to crash the app; surface in debug logs.
            assertionFailure("Store migration failed: \(error.localizedDescription)")
        }
    }
}
