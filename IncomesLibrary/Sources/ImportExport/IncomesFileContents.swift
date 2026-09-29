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
}
