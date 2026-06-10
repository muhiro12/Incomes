/// Shared input limits for simple monthly item repetition.
public enum ItemRepeatCountLimits {
    /// The minimum repeat count accepted by user-facing creation inputs.
    public static let minimum = 1
    /// The maximum repeat count accepted by user-facing creation inputs.
    public static let maximum = 60
    /// The default repeat count for user-facing creation inputs.
    public static let defaultValue = minimum
    /// The selectable repeat count range.
    public static let range = minimum...maximum
}
