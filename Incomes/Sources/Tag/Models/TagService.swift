import Foundation
import SwiftData

@MainActor
enum TagService {
    static func getAll(context: ModelContext) throws -> [Tag] {
        try context.fetch(.tags(.all))
    }

    static func getByID(context: ModelContext, id: String) throws -> Tag? {
        let persistentID = try PersistentIdentifier(base64Encoded: id)
        guard let tag = try context.fetchFirst(
            .tags(.idIs(persistentID))
        ) else {
            return nil
        }
        return tag
    }

    static func getByName(
        context: ModelContext,
        name: String,
        type: TagType
    ) throws -> Tag? {
        try context.fetchFirst(
            .tags(.nameIs(name, type: type))
        )
    }

    static func findDuplicates(
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

    static func hasDuplicates(context: ModelContext) throws -> Bool {
        let tags = try getAll(context: context)
        let duplicates = try findDuplicates(context: context, tags: tags)
        return !duplicates.isEmpty
    }

    static func mergeDuplicates(tags: [Tag]) throws {
        guard let parent = tags.first else {
            return
        }
        let children = tags.filter {
            $0.id != parent.id
        }
        for item in children.flatMap({ $0.items ?? [] }) {
            var tags = item.tags ?? []
            tags.append(parent)
            item.modify(tags: tags)
        }
        try children.forEach { child in
            try delete(tag: child)
        }
    }

    static func resolveDuplicates(
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

    static func delete(tag: Tag) throws {
        tag.delete()
    }

    static func deleteAll(context: ModelContext) throws {
        let tags = try context.fetch(FetchDescriptor<Tag>())
        tags.forEach { tag in
            tag.delete()
        }
    }
}
