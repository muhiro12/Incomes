import Foundation

/// Lightweight preview data for a tag rename before applying changes.
public struct TagRenamePreview: Equatable {
    /// Normalized stored name that would be applied on success.
    public let normalizedTargetName: String?
    /// Number of items affected by the rename.
    public let affectedItemCount: Int
    /// Validation error for the proposed target name, if any.
    public let validationError: TagRenameError?
    /// True when the normalized target matches the current stored name.
    public let isUnchanged: Bool

    /// True when the rename can be applied immediately.
    public var canApply: Bool {
        normalizedTargetName != nil
            && validationError == nil
            && isUnchanged == false
    }

    /// Creates a preview value for a pending tag rename.
    public init(
        normalizedTargetName: String?,
        affectedItemCount: Int,
        validationError: TagRenameError?,
        isUnchanged: Bool
    ) {
        self.normalizedTargetName = normalizedTargetName
        self.affectedItemCount = affectedItemCount
        self.validationError = validationError
        self.isUnchanged = isUnchanged
    }
}
