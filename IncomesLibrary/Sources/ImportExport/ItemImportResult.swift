/// Record counts an import adds, removes, and leaves unchanged.
public struct ItemImportResult: Equatable, Sendable {
    /// Items inserted from the file.
    public let addedCount: Int
    /// Store items removed.
    public let removedCount: Int
    /// Items equal on both sides and left in place.
    public let unchangedCount: Int
    /// Account names created or explicitly replaced from the reviewed file.
    public let changedLedgerCount: Int

    public init(addedCount: Int, removedCount: Int, unchangedCount: Int, changedLedgerCount: Int = 0) {
        self.addedCount = addedCount
        self.removedCount = removedCount
        self.unchangedCount = unchangedCount
        self.changedLedgerCount = changedLedgerCount
    }
}
