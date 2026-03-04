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
    ) -> [Tag] {
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
        try !duplicateTags(context: context).isEmpty
    }

    /// Returns one representative per duplicate tag group in the store.
    public static func duplicateTags(
        context: ModelContext
    ) throws -> [Tag] {
        try findDuplicates(
            context: context,
            tags: getAll(context: context)
        )
    }

    /// Returns one representative per duplicate tag group for a specific type.
    public static func duplicateTags(
        context: ModelContext,
        type: TagType
    ) throws -> [Tag] {
        try findDuplicates(
            context: context,
            tags: context.fetch(.tags(.typeIs(type)))
        )
    }

    /// Merges `tags` into the first tag, reattaching item relationships.
    public static func mergeDuplicates(tags: [Tag]) {
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
        children.forEach { child in
            delete(tag: child)
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

    /// Resolves every duplicate tag group in the store.
    public static func resolveAllDuplicates(
        context: ModelContext
    ) throws {
        try resolveDuplicates(
            context: context,
            tags: duplicateTags(context: context)
        )
    }

    /// Deletes a single tag.
    public static func delete(tag: Tag) {
        tag.delete()
    }

    /// Deletes all tags in the store.
    public static func deleteAll(context: ModelContext) throws {
        let tags = try context.fetch(FetchDescriptor<Tag>())
        tags.forEach { tag in
            tag.delete()
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

    /// Returns items for a given tag and year string.
    public static func items(
        for tag: Tag,
        yearString: String
    ) -> [Item] {
        matchingItems(for: tag)
            .filter { item in
                item.localDate.stringValueWithoutLocale(.yyyy) == yearString
            }
            .sorted()
    }

    /// Returns unique year strings for the tag items in descending order.
    public static func yearStrings(
        for tag: Tag
    ) -> [String] {
        Set(
            matchingItems(for: tag).map { item in
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
            return matchingItems(for: tags[index])
        }
    }

    /// Returns a matching date for year and year-month tags.
    public static func date(for tag: Tag) -> Date? {
        switch tag.type {
        case .year:
            return tag.name.dateValueWithoutLocale(.yyyy)
        case .yearMonth:
            return tag.name.dateValueWithoutLocale(.yyyyMM)
        case .content, .category, .debug, .none:
            return nil
        }
    }

    /// True when `tag` has the same semantic identity as any tag in `tags`.
    public static func containsEquivalentTag(
        _ tag: Tag,
        in tags: [Tag]
    ) -> Bool {
        tags.contains { candidate in
            candidate.name == tag.name && candidate.typeID == tag.typeID
        }
    }
}

private extension TagService {
    static func matchingItems(for tag: Tag) -> [Item] {
        let fallbackItems = tag.items.orEmpty
        guard
            let context = tag.modelContext,
            let tagType = tag.type,
            let items = try? context.fetch(.items(.all))
        else {
            return fallbackItems
        }

        return items.filter { item in
            switch tagType {
            case .year:
                return item.localDate.stringValueWithoutLocale(.yyyy) == tag.name
            case .yearMonth:
                return item.localDate.stringValueWithoutLocale(.yyyyMM) == tag.name
            case .content:
                return item.content == tag.name
            case .category:
                return item.category?.name == tag.name
            case .debug:
                return item.tags.orEmpty.contains { itemTag in
                    itemTag.id == tag.id
                }
            }
        }
    }
}
