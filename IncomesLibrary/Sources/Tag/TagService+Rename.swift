import Foundation
import SwiftData

public extension TagService {
    /// Renames a used category tag without mutating item rows.
    static func renameCategory(
        context: ModelContext,
        tag: Tag,
        to newName: String
    ) throws {
        guard tag.type == .category else {
            throw TagRenameError.unsupportedType
        }
        guard CategoryNameSupport.isOthersLike(tag.name) == false else {
            throw TagRenameError.uncategorizedSource
        }
        guard let normalizedTargetName = normalizedCategoryRenameTarget(
            newName
        ) else {
            throw TagRenameError.invalidTarget
        }
        guard normalizedTargetName != tag.name else {
            return
        }
        if let existingTag = try getByName(
            context: context,
            name: normalizedTargetName,
            type: .category
        ),
           existingTag.id != tag.id {
            throw TagRenameError.duplicateTargetName
        }

        tag.rename(
            storedName: normalizedTargetName
        )
    }
}

private extension TagService {
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
