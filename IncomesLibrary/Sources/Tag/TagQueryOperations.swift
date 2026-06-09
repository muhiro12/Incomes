import Foundation
import SwiftData

/// Domain operations for querying `Tag` models.
public enum TagQueryOperations {
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
        try TagType.allCases.contains { type in
            try !duplicateTags(
                context: context,
                type: type
            ).isEmpty
        }
    }

    /// True when unused tags exist in the store.
    public static func hasOrphanTags(context: ModelContext) throws -> Bool {
        try TagType.allCases.contains { type in
            try !orphanTags(
                context: context,
                type: type
            ).isEmpty
        }
    }

    /// Returns one representative per duplicate tag group in the store.
    public static func duplicateTags(
        context: ModelContext
    ) throws -> [Tag] {
        try TagType.allCases.flatMap { type in
            try duplicateTags(
                context: context,
                type: type
            )
        }
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

    /// Returns every unused tag in the store.
    public static func orphanTags(
        context: ModelContext
    ) throws -> [Tag] {
        try TagType.allCases.flatMap { type in
            try orphanTags(
                context: context,
                type: type
            )
        }
    }

    /// Returns every unused tag of `type`.
    public static func orphanTags(
        context: ModelContext,
        type: TagType
    ) throws -> [Tag] {
        try context.fetch(.tags(.typeIs(type))).filter { tag in
            isOrphan(tag: tag)
        }
    }

    /// True when `tag` is unused by every item in the current store.
    public static func isOrphan(tag: Tag) -> Bool {
        referencingItems(for: tag).isEmpty
    }

    /// Returns every item matching the semantic meaning of `tag`.
    public static func items(
        for tag: Tag
    ) -> [Item] {
        matchingItems(for: tag).sorted()
    }

    /// Returns items for a given tag and year string.
    public static func items(
        for tag: Tag,
        yearString: String
    ) -> [Item] {
        items(for: tag)
            .filter { item in
                item.localDate.stringValueWithoutLocale(.yyyy) == yearString
            }
    }

    /// Returns unique year strings for the tag items in descending order.
    public static func yearStrings(
        for tag: Tag
    ) -> [String] {
        Set(
            items(for: tag).map { item in
                item.localDate.stringValueWithoutLocale(.yyyy)
            }
        )
        .sorted(by: >)
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

    static func referencingItems(for tag: Tag) -> [Item] {
        directItems(for: tag)
    }

    static func matchingItems(for tag: Tag) -> [Item] {
        guard let tagType = tag.type else {
            return directItems(for: tag)
        }

        switch tagType {
        case .year,
             .yearMonth,
             .content,
             .debug:
            return directItems(for: tag)
        case .category:
            return categoryMatchingItems(for: tag)
        }
    }
}

private extension TagQueryOperations {
    static func directItems(for tag: Tag) -> [Item] {
        tag.items.orEmpty.filter { item in
            item.isDeleted == false
        }
    }

    static func categoryMatchingItems(for tag: Tag) -> [Item] {
        let directItems = directItems(for: tag)

        guard CategoryNameSupport.isOthersLike(tag.name),
              let context = tag.modelContext,
              let items = try? context.fetch(.items(.all)) else {
            return directItems
        }

        return items.filter { item in
            CategoryNameSupport.areEquivalent(
                item.category?.name,
                tag.name
            )
        }
    }
}
