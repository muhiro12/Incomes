import Foundation

public enum DatabaseMigrator {
    public static func migrateSQLiteFilesIfNeeded() {
        let fileManager: FileManager = .default
        let legacyURL = Database.legacyURL
        let currentURL = Database.url

        guard fileManager.fileExists(atPath: legacyURL.path),
              !fileManager.fileExists(atPath: currentURL.path) else {
            return
        }

        do {
            try fileManager.createDirectory(
                at: currentURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let legacyDir = legacyURL.deletingLastPathComponent()
            let baseName = legacyURL.lastPathComponent

            let candidateNames = try fileManager.contentsOfDirectory(atPath: legacyDir.path)
                .filter { $0 == baseName || $0.hasPrefix(baseName + "-") }

            for name in candidateNames {
                let source = legacyDir.appendingPathComponent(name)
                let destination = currentURL.deletingLastPathComponent().appendingPathComponent(name)
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
