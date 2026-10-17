import Foundation

/// File-scoped ledger references and names, resolved against the destination on import.
public struct IncomesFileLedger: Codable, Equatable, Sendable, Identifiable {
    public let id: LedgerIdentifier
    public let name: String

    public init(id: LedgerIdentifier, name: String) {
        self.id = id
        self.name = name
    }
}
