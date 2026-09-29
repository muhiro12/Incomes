/// Record counts an import adds, removes, and leaves unchanged.
public struct ItemImportResult: Equatable, Sendable {
    /// Items inserted from the file.
    public let addedCount: Int
    /// Store items removed.
    public let removedCount: Int
    /// Items equal on both sides and left in place.
    public let unchangedCount: Int
}
