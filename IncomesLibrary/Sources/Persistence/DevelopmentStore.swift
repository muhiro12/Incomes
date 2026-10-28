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

    /// Adds samples only to an empty, writable, unsynced development store.
    /// The caller's unrelated pending edits are neither saved nor discarded.
    @preconcurrency
    @MainActor
    public static func seedIfEmpty(
        context: ModelContext,
        profile: SampleDataOperations.Profile
    ) throws {
        try seedIfEmpty(context: context, profile: profile, at: Database.url)
    }

    @MainActor
    static func seedIfEmpty(
        context: ModelContext,
        profile: SampleDataOperations.Profile,
        at developmentURL: URL
    ) throws {
        try validateSampleDataTarget(context.container.configurations, at: developmentURL)
        try ItemMutationSupport.performAndSave(context: context) {
            guard try ItemQueryOperations.allItemsCount(context: context) == .zero else {
                throw DevelopmentStoreError.containsItems
            }
            try SampleDataOperations.seed(context: context, profile: profile)
        }
    }

    static func validateSampleDataTarget(
        _ configurations: Set<ModelConfiguration>,
        at developmentURL: URL
    ) throws {
        guard configurations.count == 1,
              let configuration = configurations.first,
              configuration.url.standardizedFileURL == developmentURL.standardizedFileURL,
              !configuration.isStoredInMemoryOnly,
              configuration.allowsSave,
              configuration.cloudKitContainerIdentifier == nil else {
            throw DevelopmentStoreError.invalidSampleDataTarget
        }
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
