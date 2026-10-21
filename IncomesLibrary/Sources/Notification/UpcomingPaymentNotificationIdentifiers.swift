/// Identifiers shared by payment notification producers and response routing.
public enum UpcomingPaymentNotificationIdentifiers {
    /// Prefix followed by the target item's store-local identifier.
    public static let requestIdentifierPrefix = "upcomingPayment."
    /// Separate request namespace for Settings previews.
    public static let previewRequestIdentifierPrefix = "upcomingPaymentPreview."
    /// Category assigned to payment reminders.
    public static let categoryIdentifier = "upcomingPayment"
    /// Metadata value identifying a payment reminder.
    public static let contentKind = "upcomingPayment"
    /// Action opening the reminder's item.
    public static let viewItemActionIdentifier = "viewUpcomingPaymentItem"
    /// Action opening the reminder's month.
    public static let viewMonthActionIdentifier = "viewUpcomingPaymentMonth"

    /// Request namespaces replaced when refreshing payment reminders.
    public static let managedRequestIdentifierPrefixes = [
        requestIdentifierPrefix,
        previewRequestIdentifierPrefix
    ]
}
