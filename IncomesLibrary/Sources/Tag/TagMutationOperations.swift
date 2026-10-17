import Foundation
import SwiftData

/// Domain operations for mutating `Tag` models.
public enum TagMutationOperations {
    /// Merges `tags` into the first tag, reattaching item relationships.
    public static func mergeDuplicates(tags: [Tag]) {
        guard let parent = tags.first else {
            return
        }
        if tags.contains(where: { $0.type == .ledger }),
           !tags.allSatisfy({ $0.type == .ledger && $0.name == parent.name }) {
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
            if child.type == .ledger {
                child.modelContext?.delete(child)
            } else {
                delete(tag: child)
            }
        }
    }

    /// Resolves duplicates for each tag in `tags` by searching and merging.
    public static func resolveDuplicates(
        context: ModelContext,
        tags: [Tag]
    ) throws {
        let representatives = Dictionary(grouping: tags) { tag in
            tag.typeID + "|" + tag.name
        }.values.compactMap(\.first)
        for tag in representatives {
            let duplicates = try context.fetch(
                FetchDescriptor<Tag>(predicate: TagPredicate.isSameWith(tag).value)
            )
            mergeDuplicates(
                tags: duplicates
            )
        }
    }

    /// Resolves duplicate classification groups; ledger groups require explicit selection.
    /// Returns the resolved classification group count.
    @discardableResult
    public static func resolveAllDuplicates(
        context: ModelContext
    ) throws -> Int {
        let duplicateTags = try TagQueryOperations.duplicateTags(context: context)
            .filter { $0.type != .ledger }
        try resolveDuplicates(
            context: context,
            tags: duplicateTags
        )
        return duplicateTags.count
    }

    /// Deletes a single unused tag.
    @discardableResult
    public static func delete(tag: Tag) -> Bool {
        guard tag.type != .ledger, TagQueryOperations.isOrphan(tag: tag) else {
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
            delete(tag: tag)
        }
    }

    /// Deletes every unused tag in the store and returns the deleted tag count.
    @discardableResult
    public static func deleteAllOrphanTags(
        context: ModelContext
    ) throws -> Int {
        let orphanTags = try TagQueryOperations.orphanTags(context: context)
        var deletedCount = 0
        for tag in orphanTags where delete(tag: tag) {
            deletedCount += 1
        }
        return deletedCount
    }

    /// Deletes all tags in the store.
    public static func deleteAll(context: ModelContext) throws {
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
        indices: IndexSet,
        ledgerIdentifier: LedgerIdentifier = .default
    ) -> [Item] {
        indices.flatMap { index -> [Item] in
            guard tags.indices.contains(index) else {
                return []
            }
            return TagQueryOperations.items(for: tags[index], ledgerIdentifier: ledgerIdentifier)
        }
    }
}
