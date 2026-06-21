import Foundation

/// Display values for the net income widget.
public struct WidgetNetIncomeSnapshot: Equatable, Sendable {
    public let netIncomeText: String
    public let isPositive: Bool
    public let deepLinkURL: URL

    /// Creates a net income widget snapshot.
    public init(
        netIncomeText: String,
        isPositive: Bool,
        deepLinkURL: URL
    ) {
        self.netIncomeText = netIncomeText
        self.isPositive = isPositive
        self.deepLinkURL = deepLinkURL
    }
}
