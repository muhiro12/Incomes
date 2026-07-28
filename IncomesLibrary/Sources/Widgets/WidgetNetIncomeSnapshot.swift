import Foundation

/// Display values for the net income widget.
public struct WidgetNetIncomeSnapshot: Equatable, Sendable {
    public let netIncomeText: String
    public let netIncomePresentation: ItemSummaryOperations.NetIncomePresentation
    public let deepLinkURL: URL

    /// Legacy two-state value that treats zero as nonnegative.
    @available(*, deprecated, message: "Use netIncomePresentation instead.")
    public var isPositive: Bool {
        netIncomePresentation != .negative
    }

    /// Creates a net income widget snapshot.
    public init(
        netIncomeText: String,
        netIncomePresentation: ItemSummaryOperations.NetIncomePresentation,
        deepLinkURL: URL
    ) {
        self.netIncomeText = netIncomeText
        self.netIncomePresentation = netIncomePresentation
        self.deepLinkURL = deepLinkURL
    }

    /// Creates a two-state snapshot for source compatibility.
    @available(*, deprecated, message: "Use netIncomePresentation instead.")
    public init(
        netIncomeText: String,
        isPositive: Bool,
        deepLinkURL: URL
    ) {
        self.init(
            netIncomeText: netIncomeText,
            netIncomePresentation: isPositive ? .positive : .negative,
            deepLinkURL: deepLinkURL
        )
    }
}
