/// The person's choices for a merge, applied to a reviewed difference.
public struct ItemImportMergeDecisions: Equatable, Sendable {
    /// Resolution of one change group.
    public enum Resolution: CaseIterable, Sendable {
        /// Keep the store items and ignore the file items.
        case keepCurrent
        /// Replace the store items with the file items.
        case useFile
        /// Keep the store items and add the file items.
        case keepBoth
    }

    /// Chosen resolutions; a group without an entry keeps the current items.
    public var resolutions: [ItemImportChangeGroupKey: Resolution]
    /// Positions in `ItemImportDifference.additions` that must not be added.
    public var excludedAdditionIndices: Set<Int>
    /// Existing ledger names stay unchanged unless the review explicitly selects the file.
    public var useFileLedgerNames: Bool

    /// Creates decisions that keep current items and add every addition by default.
    public init(
        resolutions: [ItemImportChangeGroupKey: Resolution] = [:],
        excludedAdditionIndices: Set<Int> = [],
        useFileLedgerNames: Bool = false
    ) {
        self.resolutions = resolutions
        self.excludedAdditionIndices = excludedAdditionIndices
        self.useFileLedgerNames = useFileLedgerNames
    }
}

public extension ItemImportMergeDecisions {
    /// Resolution chosen for `key`, keeping the current items by default.
    func resolution(for key: ItemImportChangeGroupKey) -> Resolution {
        resolutions[key] ?? .keepCurrent
    }
}
