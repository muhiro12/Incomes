import Foundation

/// Validated contents of an Incomes file, converted to the current representation.
public struct IncomesFileContents: Equatable, Sendable {
    /// Schema version that wrote the file, such as `2.0.0`.
    public let schemaVersion: String
    /// Moment the file was written.
    public let exportedAt: Date
    /// Currency setting recorded with the items, when present.
    public let currencyCode: String?
    /// Items in value order.
    public let items: [IncomesFileItem]
    /// Includes empty accounts; independent of the Item collection.
    public let ledgers: [IncomesFileLedger]
    /// Replace is restricted to these explicit account identities.
    public let selectionLedgerIdentifiers: Set<LedgerIdentifier>

    public init(
        schemaVersion: String,
        exportedAt: Date,
        currencyCode: String?,
        items: [IncomesFileItem],
        ledgers: [IncomesFileLedger] = [],
        selectionLedgerIdentifiers: Set<LedgerIdentifier> = [.default]
    ) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.currencyCode = currencyCode
        self.items = items
        self.ledgers = ledgers
        self.selectionLedgerIdentifiers = selectionLedgerIdentifiers
    }
}
