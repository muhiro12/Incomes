/// Summary flags used to populate the settings screen.
public struct SettingsStatus {
    /// True when duplicate tags exist in the store.
    public let hasDuplicateTags: Bool
    /// True when unused tags exist in the store.
    public let hasOrphanTags: Bool
    /// True when tutorial or debug sample data exists.
    public let hasDebugData: Bool

    /// Creates a settings status snapshot.
    public init(
        hasDuplicateTags: Bool,
        hasOrphanTags: Bool,
        hasDebugData: Bool
    ) {
        self.hasDuplicateTags = hasDuplicateTags
        self.hasOrphanTags = hasOrphanTags
        self.hasDebugData = hasDebugData
    }
}
