import Foundation
import SwiftData

/// Utilities to search, deduplicate, and manage `Tag` models.
public enum TagService {
    /// Returns all tags in the store.
    public static func getAll(context: ModelContext) throws -> [Tag] {
        try context.fetch(.tags(.all))
    }

    /// Loads a `Tag` by Base64-encoded persistent identifier.
    public static func getByID(context: ModelContext, id: String) throws -> Tag? {
        let persistentID = try PersistentIdentifier(base64Encoded: id)
        guard let tag = try context.fetchFirst(
            .tags(.idIs(persistentID))
        ) else {
            return nil
        }
        return tag
    }

    /// Finds a tag by name and type.
    public static func getByName(
        context: ModelContext,
        name: String,
        type: TagType
    ) throws -> Tag? {
        try context.fetchFirst(
            .tags(.nameIs(name, type: type))
        )
    }

    /// Returns one representative per duplicate group in the provided tags.
    public static func findDuplicates(
        context _: ModelContext,
        tags: [Tag]
    ) throws -> [Tag] {
        Dictionary(grouping: tags) { tag in
            tag.typeID + tag.name
        }
        .compactMap { _, values -> Tag? in
            guard values.count > 1 else {
                return nil
            }
            return values.first
        }
    }

    /// True when duplicate tags exist in the store.
    public static func hasDuplicates(context: ModelContext) throws -> Bool {
        let tags = try getAll(context: context)
        let duplicates = try findDuplicates(context: context, tags: tags)
        return !duplicates.isEmpty
    }

    /// Merges `tags` into the first tag, reattaching item relationships.
    public static func mergeDuplicates(tags: [Tag]) throws {
        guard let parent = tags.first else {
            return
        }
        let children = tags.filter { tag in
            tag.id != parent.id
        }
        let childItems = children.flatMap { tag in
            tag.items ?? []
        }
        for item in childItems {
            var tags = item.tags ?? []
            tags.append(parent)
            item.modify(tags: tags)
        }
        try children.forEach { child in
            try delete(tag: child)
        }
    }

    /// Resolves duplicates for each tag in `tags` by searching and merging.
    public static func resolveDuplicates(
        context: ModelContext,
        tags: [Tag]
    ) throws {
        for tag in tags {
            let duplicates = try context.fetch(
                .tags(.isSameWith(tag))
            )
            try mergeDuplicates(
                tags: duplicates
            )
        }
    }

    /// Deletes a single tag.
    public static func delete(tag: Tag) throws {
        tag.delete()
    }

    /// Deletes all tags in the store.
    public static func deleteAll(context: ModelContext) throws {
        let tags = try context.fetch(FetchDescriptor<Tag>())
        tags.forEach { tag in
            tag.delete()
        }
    }

    /// Returns items for a given tag and year string.
    public static func items(
        for tag: Tag,
        yearString: String
    ) -> [Item] {
        tag.items.orEmpty
            .filter { item in
                item.year?.name == yearString
            }
            .sorted()
    }

    /// Returns unique year strings for the tag items in descending order.
    public static func yearStrings(
        for tag: Tag
    ) -> [String] {
        Set(
            tag.items.orEmpty.map { item in
                item.localDate.stringValueWithoutLocale(.yyyy)
            }
        )
        .sorted(by: >)
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
            return tags[index].items.orEmpty
        }
    }
}
