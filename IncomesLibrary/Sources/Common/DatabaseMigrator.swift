import Foundation

/// Migrates legacy database files into the shared store location.
public enum DatabaseMigrator {
    /// Moves the legacy SQLite store into the current location when required.
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
              !fileManager.fileExists(atPath: currentURL.path) else {
            return
        }

        do {
            try fileManager.createDirectory(
                at: currentURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let legacyDirectory = legacyURL.deletingLastPathComponent()
            let currentDirectory = currentURL.deletingLastPathComponent()
            let baseName = legacyURL.lastPathComponent

            let directoryContents = try fileManager.contentsOfDirectory(
                atPath: legacyDirectory.path
            )
            let candidateNames = directoryContents.filter { name in
                name == baseName || name.hasPrefix(baseName + "-")
            }

            for name in candidateNames {
                let source = legacyDirectory.appendingPathComponent(name)
                let destination = currentDirectory.appendingPathComponent(name)
                do {
                    try fileManager.moveItem(at: source, to: destination)
                } catch {
                    if !fileManager.fileExists(atPath: destination.path) {
                        try fileManager.copyItem(at: source, to: destination)
                    }
                }
            }
        } catch {
            assertionFailure("Store migration failed: \(error.localizedDescription)")
        }
    }
}
