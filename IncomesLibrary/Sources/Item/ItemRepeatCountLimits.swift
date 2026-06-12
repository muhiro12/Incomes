/// Shared input limits for simple monthly item repetition.
enum ItemRepeatCountLimits {
    /// The minimum repeat count accepted by user-facing creation inputs.
    static let minimum = 1
    /// The maximum repeat count accepted by user-facing creation inputs.
    static let maximum = 60
    /// The default repeat count for user-facing creation inputs.
    static let defaultValue = minimum
    /// The selectable repeat count range.
    static let range = minimum...maximum
}
