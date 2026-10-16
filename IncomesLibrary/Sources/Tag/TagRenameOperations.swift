import Foundation
import SwiftData

/// Domain operations for renaming category tags.
public enum TagRenameOperations {
    /// Returns whether `tag` can be renamed as a user-managed category.
    public static func canRenameCategory(_ tag: Tag) -> Bool {
        tag.type == .category
            && CategoryNameSupport.isOthersLike(tag.name) == false
    }

    /// Returns a lightweight preview for renaming a category tag.
    public static func previewCategoryRename(
        context: ModelContext,
        tag: Tag,
        to newName: String,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> TagRenamePreview {
        try validateCategoryRenameSource(tag)

        let affectedItemCount = TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier).count
        guard
            let normalizedTargetName = normalizedCategoryRenameTarget(
                newName
            )
        else {
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
            type: .category,
            ledgerIdentifier: ledgerIdentifier
        ),
        existingTag.id != tag.id,
        !TagQueryOperations.items(for: existingTag, ledgerIdentifier: ledgerIdentifier).isEmpty {
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
        to newName: String,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws {
        let preview = try previewCategoryRename(
            context: context,
            tag: tag,
            to: newName,
            ledgerIdentifier: ledgerIdentifier
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

        let members = TagQueryOperations.items(for: tag)
        let existingTarget = try TagQueryOperations.getByName(
            context: context,
            name: normalizedTargetName,
            type: .category
        )
        if existingTarget == nil, members.allSatisfy({ $0.ledgerIdentifier == ledgerIdentifier }) {
            tag.rename(storedName: normalizedTargetName)
            return
        }
        let target = try Tag.create(context: context, name: normalizedTargetName, type: .category)
        for item in TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier) {
            item.modify(tags: (item.tags ?? []).filter { $0.id != tag.id } + [target])
        }
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
        guard !trimmedName.isEmpty else {
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
