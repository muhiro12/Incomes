/// How a reviewed import changes the store inside the file's selection.
public enum ItemImportPolicy: Equatable, Sendable {
    /// Makes the store equal to the file; matched items stay in place.
    case replace
    /// Adds the file's differences without removing store items unless a group says so.
    case merge(ItemImportMergeDecisions)
}
