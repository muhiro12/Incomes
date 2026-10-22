import Foundation

/// Book metadata read from its dedicated Tag, including unavailable explicit identities.
public struct LedgerRecord: Identifiable, Equatable, Sendable {
    public let id: LedgerIdentifier
    public let name: String
    public let issue: LedgerError?
    /// True when a user-provided name replaces the localized system name.
    public let isNameCustomized: Bool

    /// Missing or conflicting metadata never becomes the original ledger.
    public var isAvailable: Bool {
        issue == nil
    }

    init(
        id: LedgerIdentifier,
        name: String,
        issue: LedgerError? = nil,
        isNameCustomized: Bool = false
    ) {
        self.id = id
        self.name = name
        self.issue = issue
        self.isNameCustomized = isNameCustomized
    }
}
