/// Reasons an Incomes file cannot be read or applied. None of them changes the store.
public enum ItemImportError: Error, Equatable, Sendable {
    /// The file exceeds the supported size.
    case fileTooLarge
    /// The data is not an Incomes file.
    case unrecognizedFormat
    /// The data claims to be an Incomes file but is not valid JSON of that shape.
    case malformedFile
    /// A newer version of Incomes wrote the file.
    case newerSchemaVersion(String)
    /// No supported reader exists for the file's version.
    case unsupportedSchemaVersion(String)
    /// The file covers a selection this version cannot interpret.
    case unsupportedSelection
    /// The item at `index` has an invalid `field`.
    case invalidItem(index: Int, field: IncomesFileItem.Field)
    /// The store changed after the difference was reviewed.
    case storeChangedSinceReview
}
