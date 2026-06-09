import Foundation
import SwiftData

/// Domain operations for renaming category tags.
public enum TagRenameOperations {
    /// Returns a lightweight preview for renaming a category tag.
    public static func previewCategoryRename(
        context: ModelContext,
        tag: Tag,
        to newName: String
    ) throws -> TagRenamePreview {
        try validateCategoryRenameSource(tag)

        let affectedItemCount = TagQueryOperations.items(for: tag).count
        guard let normalizedTargetName = normalizedCategoryRenameTarget(
            newName
        ) else {
            return .init(
                normalizedTargetName: nil,
                affectedItemCount: affectedItemCount,
                validationError: .invalidTarget,
                isUnchanged: false
            )
        }
        guard normalizedTargetName != tag.name else {
            return .init(
                normalizedTargetName: normalizedTargetName,
                affectedItemCount: affectedItemCount,
                validationError: nil,
                isUnchanged: true
            )
        }
        if let existingTag = try TagQueryOperations.getByName(
            context: context,
            name: normalizedTargetName,
            type: .category
        ),
        existingTag.id != tag.id {
            return .init(
                normalizedTargetName: normalizedTargetName,
                affectedItemCount: affectedItemCount,
                validationError: .duplicateTargetName,
                isUnchanged: false
            )
        }

        return .init(
            normalizedTargetName: normalizedTargetName,
            affectedItemCount: affectedItemCount,
            validationError: nil,
            isUnchanged: false
        )
    }

    /// Renames a used category tag without mutating item rows.
    public static func renameCategory(
        context: ModelContext,
        tag: Tag,
        to newName: String
    ) throws {
        let preview = try previewCategoryRename(
            context: context,
            tag: tag,
            to: newName
        )
        if let validationError = preview.validationError {
            throw validationError
        }
        guard let normalizedTargetName = preview.normalizedTargetName else {
            throw TagRenameError.invalidTarget
        }
        guard preview.isUnchanged == false else {
            return
        }

        tag.rename(
            storedName: normalizedTargetName
        )
    }
}

private extension TagRenameOperations {
    static func validateCategoryRenameSource(
        _ tag: Tag
    ) throws {
        guard tag.type == .category else {
            throw TagRenameError.unsupportedType
        }
        guard CategoryNameSupport.isOthersLike(tag.name) == false else {
            throw TagRenameError.uncategorizedSource
        }
    }

    static func normalizedCategoryRenameTarget(
        _ rawName: String
    ) -> String? {
        let trimmedName = rawName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard trimmedName.isNotEmpty else {
            return nil
        }

        let normalizedTargetName = CategoryNameSupport.normalizedStoredName(
            forUserInput: trimmedName
        )
        guard CategoryNameSupport.isOthersLike(normalizedTargetName) == false else {
            return nil
        }

        return normalizedTargetName
    }
}
