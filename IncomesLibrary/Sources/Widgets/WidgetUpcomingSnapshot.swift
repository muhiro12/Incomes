import Foundation

/// Display values for the upcoming item widget.
public struct WidgetUpcomingSnapshot: Equatable, Sendable {
    public let subtitleText: String
    public let titleText: String
    public let detailText: String
    public let amountText: String
    public let isPositive: Bool
    public let deepLinkURL: URL

    /// Creates an upcoming item widget snapshot.
    public init(
        subtitleText: String,
        titleText: String,
        detailText: String,
        amountText: String,
        isPositive: Bool,
        deepLinkURL: URL
    ) {
        self.subtitleText = subtitleText
        self.titleText = titleText
        self.detailText = detailText
        self.amountText = amountText
        self.isPositive = isPositive
        self.deepLinkURL = deepLinkURL
    }
}
