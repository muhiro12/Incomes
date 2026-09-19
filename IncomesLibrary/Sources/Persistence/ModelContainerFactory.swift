import Foundation
import SwiftData

/// Shared schema and container construction for app, extensions, and transient stores.
public enum ModelContainerFactory {
    /// Opens a store with the complete migration plan. Only the host app owns migration.
    public static func make(configuration: ModelConfiguration) throws -> ModelContainer {
        try .init(
            for: Schema(versionedSchema: IncomesSchemaV3.self),
            migrationPlan: IncomesSchemaMigrationPlan.self,
            configurations: [configuration]
        )
    }

    /// Creates a local extension container without running the host's migration plan.
    public static func shared() throws -> ModelContainer {
        try readOnly(at: Database.url)
    }

    /// Creates a context owned by the calling process.
    public static func sharedContext() throws -> ModelContext {
        .init(try shared())
    }

    /// Creates an isolated, unsynced container for previews and Watch snapshots.
    public static func inMemory() throws -> ModelContainer {
        try make(configuration: .init(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
    }
}

extension ModelContainerFactory {
    // Extensions read the shared database; startup and migration belong to the app.
    static func readOnly(at url: URL) throws -> ModelContainer {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        return try .init(
            for: Schema(versionedSchema: IncomesSchemaV3.self),
            configurations: [.init(url: url, allowsSave: false, cloudKitDatabase: .none)]
        )
    }
}
