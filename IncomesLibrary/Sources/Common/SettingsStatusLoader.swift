import SwiftData

/// Loads derived status flags for the settings screen.
public enum SettingsStatusLoader {
    /// Computes the current settings status from the store.
    public static func load(
        context: ModelContext
    ) throws -> SettingsStatus {
        let hasDuplicateTags = try TagService.hasDuplicates(context: context)
        let hasDebugData = try ItemService.hasDebugData(context: context)
        return .init(
            hasDuplicateTags: hasDuplicateTags,
            hasDebugData: hasDebugData
        )
    }
}
