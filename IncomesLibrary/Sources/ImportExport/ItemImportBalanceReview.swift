/// Balance differences that can be reviewed without changing the store.
public struct ItemImportBalanceReview: Equatable, Sendable {
    /// True when retaining exported baselines can differ from recalculation.
    public let hasDifferences: Bool
    /// Remaining native identity ties can change the last displayed saved balance after restoration.
    public let hasAmbiguousOrder: Bool
    /// False when recalculation would exceed the exact amount boundary.
    public let canRecalculate: Bool
}
