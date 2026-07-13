import Foundation
import SwiftData

/// Domain operations for mutating `Tag` models.
public enum TagMutationOperations {
    /// Merges `tags` into the first tag, reattaching item relationships.
    ///
    /// This compatibility overload rolls back and returns without persisting when saving fails.
    /// Prefer ``mergeDuplicates(context:tags:)`` when the caller can handle errors.
    public static func mergeDuplicates(tags: [Tag]) {
        guard let context = tags.lazy.compactMap(\.modelContext).first else {
            return
        }

        do {
            try mergeDuplicates(context: context, tags: tags)
        } catch {
            assertionFailure("Failed to merge duplicate tags: \(error)")
        }
    }

    /// Merges `tags` into the first tag and persists the mutation atomically.
    public static func mergeDuplicates(
        context: ModelContext,
        tags: [Tag]
    ) throws {
        try ModelContextMutationOperations.run(context: context) {
            mergeDuplicatesWithoutSaving(tags: tags)
        }
    }

    static func mergeDuplicatesWithoutSaving(tags: [Tag]) {
        guard let parent = tags.first else {
            return
        }
        let children = tags.filter { tag in
            tag.id != parent.id
        }
        let childIDs = Set(children.map(\.id))
        let childItems = Array(
            Dictionary(
                grouping: children.flatMap { tag in
                    TagQueryOperations.referencingItems(for: tag)
                },
                by: \.id
            )
            .values
            .compactMap(\.first)
        )
        for item in childItems {
            var tags = (item.tags ?? []).filter { tag in
                !childIDs.contains(tag.id)
            }
            guard tags.contains(parent) == false else {
                item.modify(tags: tags)
                continue
            }
            tags.append(parent)
            item.modify(tags: tags)
        }
        children.forEach { child in
            _ = deleteWithoutSaving(tag: child)
        }
    }

    /// Resolves duplicates for each tag in `tags` by searching and merging.
    public static func resolveDuplicates(
        context: ModelContext,
        tags: [Tag]
    ) throws {
        try ModelContextMutationOperations.run(context: context) {
            try resolveDuplicatesWithoutSaving(
                context: context,
                tags: tags
            )
        }
    }

    static func resolveDuplicatesWithoutSaving(
        context: ModelContext,
        tags: [Tag]
    ) throws {
        for tag in tags {
            let duplicates = try context.fetch(
                .tags(.isSameWith(tag))
            )
            mergeDuplicatesWithoutSaving(
                tags: duplicates
            )
        }
    }

    /// Resolves every duplicate tag group in the store and returns the resolved group count.
    @discardableResult
    public static func resolveAllDuplicates(
        context: ModelContext
    ) throws -> Int {
        try ModelContextMutationOperations.run(context: context) {
            let duplicateTags = try TagQueryOperations.duplicateTags(context: context)
            try resolveDuplicatesWithoutSaving(
                context: context,
                tags: duplicateTags
            )
            return duplicateTags.count
        }
    }

    /// Deletes a single unused tag.
    ///
    /// This compatibility overload rolls back and returns `false` when saving fails.
    /// Prefer ``delete(context:tag:)`` when the caller can handle errors.
    @discardableResult
    public static func delete(tag: Tag) -> Bool {
        guard let context = tag.modelContext else {
            return false
        }

        do {
            return try delete(context: context, tag: tag)
        } catch {
            assertionFailure("Failed to delete tag: \(error)")
            return false
        }
    }

    /// Deletes a single unused tag and persists the mutation atomically.
    @discardableResult
    public static func delete(
        context: ModelContext,
        tag: Tag
    ) throws -> Bool {
        try ModelContextMutationOperations.run(context: context) {
            deleteWithoutSaving(tag: tag)
        }
    }

    static func deleteWithoutSaving(tag: Tag) -> Bool {
        guard TagQueryOperations.isOrphan(tag: tag) else {
            return false
        }
        tag.modelContext?.delete(tag)
        return true
    }

    static func deleteUnused(tags: [Tag]) {
        let uniqueTags = Dictionary(
            grouping: tags,
            by: \.id
        )
        .compactMap(\.value.first)
        uniqueTags.forEach { tag in
            _ = deleteWithoutSaving(tag: tag)
        }
    }

    /// Deletes every unused tag in the store and returns the deleted tag count.
    @discardableResult
    public static func deleteAllOrphanTags(context: ModelContext) throws -> Int {
        try ModelContextMutationOperations.run(context: context) {
            let orphanTags = try TagQueryOperations.orphanTags(context: context)
            var deletedCount = 0
            for tag in orphanTags where deleteWithoutSaving(tag: tag) {
                deletedCount += 1
            }
            return deletedCount
        }
    }

    /// Deletes all tags in the store.
    public static func deleteAll(context: ModelContext) throws {
        try ModelContextMutationOperations.run(context: context) {
            try deleteAllWithoutSaving(context: context)
        }
    }

    static func deleteAllWithoutSaving(context: ModelContext) throws {
        let tags = try context.fetch(FetchDescriptor<Tag>())
        tags.forEach { tag in
            tag.modelContext?.delete(tag)
        }
    }

    /// Returns the selected tags for deletion based on list indices.
    public static func resolveTagsForDeletion(
        from tags: [Tag],
        indices: IndexSet
    ) -> [Tag] {
        indices.compactMap { index in
            guard tags.indices.contains(index) else {
                return nil
            }
            return tags[index]
        }
    }

    /// Resolves items for deletion based on selected tag indices.
    public static func resolveItemsForDeletion(
        from tags: [Tag],
        indices: IndexSet
    ) -> [Item] {
        indices.flatMap { index -> [Item] in
            guard tags.indices.contains(index) else {
                return []
            }
            return TagQueryOperations.matchingItems(for: tags[index])
        }
    }
}
