#if DEBUG
import Foundation
import SwiftData

/// Opens the persistent, unsynced development store without modifying released stores.
public enum DevelopmentStore {
    /// Seeds only when creating the database file. Disabling seeding never deletes data.
    @preconcurrency
    @MainActor
    public static func makeContainer(automaticallySeedsSampleData: Bool = true) throws -> ModelContainer {
        try makeContainer(at: Database.url, automaticallySeedsSampleData: automaticallySeedsSampleData)
    }

    @MainActor
    static func makeContainer(
        at url: URL,
        automaticallySeedsSampleData: Bool,
        baseDate: Date = .now,
        locale: Locale = .current
    ) throws -> ModelContainer {
        let storeExists = FileManager.default.fileExists(atPath: url.path)
        let container = try ModelContainerFactory.make(
            configuration: .init(url: url, cloudKitDatabase: .none)
        )
        // An existing empty database may have been deliberately cleared.
        // Even a failed initial seed must not make future launches refill it.
        if !storeExists, automaticallySeedsSampleData {
            // The UI fetches saved records instead of retaining newly inserted identities.
            try SampleDataOperations.seedAndSave(
                context: ModelContext(container),
                profile: .standard,
                baseDate: baseDate,
                locale: locale
            )
        }
        return container
    }
}
#endif
