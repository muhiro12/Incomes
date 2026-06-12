/// Reason a test notification presentation could not be prepared.
public enum UpcomingPaymentTestNoticeReason: String, Sendable {
    /// No future item exists for a test notification.
    case noItem = "no_item"
    /// A future item exists, but no presentation could be built.
    case noPresentation = "no_presentation"
}
