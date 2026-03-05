import SwiftData

/// Documented for SwiftLint compliance.
public enum SettingsStatusLoader {
    /// Documented for SwiftLint compliance.
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
