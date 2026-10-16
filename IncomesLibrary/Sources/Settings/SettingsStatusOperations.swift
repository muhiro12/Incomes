import SwiftData

/// Loads derived status flags for the settings screen.
public enum SettingsStatusOperations {
    /// Computes the current settings status from the store.
    public static func load(
        context: ModelContext,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> SettingsStatus {
        let hasDuplicateTags = try TagQueryOperations.hasDuplicates(
            context: context,
            ledgerIdentifier: ledgerIdentifier
        )
        let hasOrphanTags = try TagQueryOperations.hasOrphanTags(
            context: context,
            ledgerIdentifier: ledgerIdentifier
        )
        let hasDebugData = try SampleDataOperations.hasDebugData(context: context)
        return .init(
            hasDuplicateTags: hasDuplicateTags,
            hasOrphanTags: hasOrphanTags,
            hasDebugData: hasDebugData
        )
    }
}
