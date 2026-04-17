import Foundation

/// Validation failures for safe tag rename operations.
public enum TagRenameError: Error, Equatable {
    case unsupportedType
    case uncategorizedSource
    case invalidTarget
    case duplicateTargetName
}
