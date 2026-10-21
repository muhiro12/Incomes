/// A portable snapshot and the ordering changes that need explanation before export.
public struct ItemExportPreparation: Sendable {
    public let items: [IncomesFileItem]
    /// Records whose file-only priority differs from the source value.
    public let adjustedPriorityCount: Int
    /// Ledger-days whose native tie order cannot fit the standard editor priority range.
    public let unresolvedDayCount: Int
}
