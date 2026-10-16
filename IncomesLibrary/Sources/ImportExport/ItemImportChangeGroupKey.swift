import Foundation

/// Date and description shared by the items of one change group.
public struct ItemImportChangeGroupKey: Hashable, Sendable {
    /// A same-date/name group never crosses financial owners.
    public let ledgerIdentifier: LedgerIdentifier
    /// Stored calendar day at UTC midnight.
    public let date: Date
    /// Shared item description.
    public let content: String

    public init(date: Date, content: String, ledgerIdentifier: LedgerIdentifier = .default) {
        self.date = date
        self.content = content
        self.ledgerIdentifier = ledgerIdentifier
    }
}
