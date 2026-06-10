import SwiftData

/// Loads derived status flags for the settings screen.
public enum SettingsStatusOperations {
    /// Computes the current settings status from the store.
    public static func load(
        context: ModelContext
    ) throws -> SettingsStatus {
        let hasDuplicateTags = try TagQueryOperations.hasDuplicates(context: context)
        let hasOrphanTags = try TagQueryOperations.hasOrphanTags(context: context)
        let hasDebugData = try SampleDataOperations.hasDebugData(context: context)
        return .init(
            hasDuplicateTags: hasDuplicateTags,
            hasOrphanTags: hasOrphanTags,
            hasDebugData: hasDebugData
        )
    }
}
