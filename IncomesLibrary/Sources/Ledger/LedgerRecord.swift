import Foundation

/// Book metadata read from its dedicated Tag, including unavailable explicit identities.
public struct LedgerRecord: Identifiable, Equatable, Sendable {
    public let id: LedgerIdentifier
    public let name: String
    public let issue: LedgerError?

    /// Missing or conflicting metadata never becomes the original account.
    public var isAvailable: Bool {
        issue == nil
    }

    init(
        id: LedgerIdentifier,
        name: String,
        issue: LedgerError? = nil
    ) {
        self.id = id
        self.name = name
        self.issue = issue
    }
}
