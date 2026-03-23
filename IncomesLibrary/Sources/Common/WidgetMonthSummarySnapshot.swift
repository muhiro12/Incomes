import Foundation

/// Display values for the month summary widget.
public struct WidgetMonthSummarySnapshot: Equatable, Sendable {
    public let totalIncomeText: String
    public let totalOutgoText: String
    public let deepLinkURL: URL?

    /// Creates a month summary widget snapshot.
    public init(
        totalIncomeText: String,
        totalOutgoText: String,
        deepLinkURL: URL?
    ) {
        self.totalIncomeText = totalIncomeText
        self.totalOutgoText = totalOutgoText
        self.deepLinkURL = deepLinkURL
    }
}
