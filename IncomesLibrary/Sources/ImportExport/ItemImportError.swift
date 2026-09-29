import Foundation

/// Reasons an Incomes file cannot be read or applied. None of them changes the store.
public enum ItemImportError: LocalizedError, Equatable, Sendable {
    /// The file exceeds the supported size.
    case fileTooLarge
    /// The data is not an Incomes file, or is too damaged to identify.
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

    public var errorDescription: String? {
        switch self {
        case .fileTooLarge:
            String(localized: "This file is too large to import.", bundle: .module)
        case .unrecognizedFormat:
            String(localized: "This file is not an Incomes data file, or it is damaged.", bundle: .module)
        case .malformedFile:
            String(localized: "This file is damaged and cannot be read.", bundle: .module)
        case .newerSchemaVersion,
             .unsupportedSelection:
            String(
                localized: "A newer version of Incomes created this file. Update Incomes and try again.",
                bundle: .module
            )
        case .unsupportedSchemaVersion:
            String(localized: "This version of the file is not supported.", bundle: .module)
        case .invalidItem(let index, _):
            String(localized: "Item \(index + 1) in the file has an invalid value.", bundle: .module)
        case .storeChangedSinceReview:
            String(
                localized: "Your data changed while you were reviewing. Review the import again.",
                bundle: .module
            )
        }
    }
}
