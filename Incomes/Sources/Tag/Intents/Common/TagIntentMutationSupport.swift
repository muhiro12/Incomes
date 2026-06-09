import SwiftData

enum TagIntentMutationSupport {
    static func renameCategory(
        tag: TagEntity,
        to newName: String,
        context: ModelContext
    ) throws -> TagEntity {
        let model = try tag.model(in: context)
        try TagRenameOperations.renameCategory(
            context: context,
            tag: model,
            to: newName
        )
        return try TagEntity.make(from: model)
    }

    static func deleteAllOrphanTags(context: ModelContext) throws -> Int {
        try TagMutationOperations.deleteAllOrphanTags(
            context: context
        )
    }

    static func resolveAllDuplicates(context: ModelContext) throws -> Int {
        try TagMutationOperations.resolveAllDuplicates(
            context: context
        )
    }
}
