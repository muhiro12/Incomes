/// Result of preparing a test notification presentation.
public enum UpcomingPaymentTestNoticeResult: Sendable {
    /// A display-ready presentation is available.
    case presentation(UpcomingPaymentNotificationPresentation)
    /// A presentation could not be prepared.
    case unavailable(UpcomingPaymentTestNoticeReason)
}
