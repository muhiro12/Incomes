/// Documented for SwiftLint compliance.
public struct SettingsStatus {
    /// Documented for SwiftLint compliance.
    public let hasDuplicateTags: Bool
    /// Documented for SwiftLint compliance.
    public let hasDebugData: Bool

    /// Documented for SwiftLint compliance.
    public init(
        hasDuplicateTags: Bool,
        hasDebugData: Bool
    ) {
        self.hasDuplicateTags = hasDuplicateTags
        self.hasDebugData = hasDebugData
    }
}
