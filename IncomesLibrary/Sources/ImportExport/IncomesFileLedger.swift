import Foundation

/// Portable account metadata. Unknown forecast JSON is preserved without interpreting it.
public struct IncomesFileLedger: Codable, Equatable, Sendable, Identifiable {
    public let id: LedgerIdentifier
    public let name: String

    public init(id: LedgerIdentifier, name: String) {
        self.id = id
        self.name = name
    }
}
