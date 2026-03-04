import Foundation

/// A display-ready notification payload for an upcoming payment reminder.
public struct UpcomingPaymentNotificationPresentation: Sendable {
    public enum InterruptionLevel: Sendable, Equatable {
        case active
    }

    public static let requestIdentifierPrefix = "upcoming-payment:"
    public static let previewRequestIdentifierPrefix = "upcoming-payment-preview:"

    public let requestIdentifier: String
    public let primaryRouteURL: URL
    public let secondaryRouteURL: URL
    public let threadIdentifier: String
    public let targetContentIdentifier: String
    public let summaryArgument: String
    public let summaryArgumentCount: Int
    public let badgeCount: Int
    public let daysUntilDue: Int
    public let relevanceScore: Double
    public let interruptionLevel: InterruptionLevel
    public let itemContent: String
    public let amount: Decimal
    public let dueDate: Date
    public let notifyDate: Date

    public init(
        requestIdentifier: String,
        primaryRouteURL: URL,
        secondaryRouteURL: URL,
        threadIdentifier: String,
        targetContentIdentifier: String,
        summaryArgument: String,
        summaryArgumentCount: Int,
        badgeCount: Int,
        daysUntilDue: Int,
        relevanceScore: Double,
        interruptionLevel: InterruptionLevel,
        itemContent: String,
        amount: Decimal,
        dueDate: Date,
        notifyDate: Date
    ) {
        self.requestIdentifier = requestIdentifier
        self.primaryRouteURL = primaryRouteURL
        self.secondaryRouteURL = secondaryRouteURL
        self.threadIdentifier = threadIdentifier
        self.targetContentIdentifier = targetContentIdentifier
        self.summaryArgument = summaryArgument
        self.summaryArgumentCount = summaryArgumentCount
        self.badgeCount = badgeCount
        self.daysUntilDue = daysUntilDue
        self.relevanceScore = relevanceScore
        self.interruptionLevel = interruptionLevel
        self.itemContent = itemContent
        self.amount = amount
        self.dueDate = dueDate
        self.notifyDate = notifyDate
    }

    public func previewPresentation() -> Self {
        .init(
            requestIdentifier: Self.previewRequestIdentifierPrefix + targetContentIdentifier,
            primaryRouteURL: primaryRouteURL,
            secondaryRouteURL: secondaryRouteURL,
            threadIdentifier: threadIdentifier,
            targetContentIdentifier: targetContentIdentifier,
            summaryArgument: summaryArgument,
            summaryArgumentCount: summaryArgumentCount,
            badgeCount: badgeCount,
            daysUntilDue: daysUntilDue,
            relevanceScore: relevanceScore,
            interruptionLevel: interruptionLevel,
            itemContent: itemContent,
            amount: amount,
            dueDate: dueDate,
            notifyDate: notifyDate
        )
    }
}
