import Foundation

/// Display values for the upcoming item widget.
public struct WidgetUpcomingSnapshot: Equatable, Sendable {
    public let subtitleText: String
    public let titleText: String
    public let detailText: String
    public let amountText: String
    public let netIncomePresentation: ItemSummaryOperations.NetIncomePresentation
    public let deepLinkURL: URL

    /// Legacy two-state value that treats zero as nonnegative.
    @available(*, deprecated, message: "Use netIncomePresentation instead.")
    public var isPositive: Bool {
        netIncomePresentation != .negative
    }

    /// Creates an upcoming item widget snapshot.
    public init(
        subtitleText: String,
        titleText: String,
        detailText: String,
        amountText: String,
        netIncomePresentation: ItemSummaryOperations.NetIncomePresentation,
        deepLinkURL: URL
    ) {
        self.subtitleText = subtitleText
        self.titleText = titleText
        self.detailText = detailText
        self.amountText = amountText
        self.netIncomePresentation = netIncomePresentation
        self.deepLinkURL = deepLinkURL
    }

    /// Creates a two-state snapshot for source compatibility.
    @available(*, deprecated, message: "Use netIncomePresentation instead.")
    public init(
        subtitleText: String,
        titleText: String,
        detailText: String,
        amountText: String,
        isPositive: Bool,
        deepLinkURL: URL
    ) {
        self.init(
            subtitleText: subtitleText,
            titleText: titleText,
            detailText: detailText,
            amountText: amountText,
            netIncomePresentation: isPositive ? .positive : .negative,
            deepLinkURL: deepLinkURL
        )
    }
}
