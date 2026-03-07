/// Summary flags used to populate the settings screen.
public struct SettingsStatus {
    /// True when duplicate tags exist in the store.
    public let hasDuplicateTags: Bool
    /// True when tutorial or debug sample data exists.
    public let hasDebugData: Bool

    /// Creates a settings status snapshot.
    public init(
        hasDuplicateTags: Bool,
        hasDebugData: Bool
    ) {
        self.hasDuplicateTags = hasDuplicateTags
        self.hasDebugData = hasDebugData
    }
}
