import Foundation
import SwiftData

@MainActor
enum TagService {
    static func getAll(context: ModelContext) throws -> [TagEntity] {
        let tags = try context.fetch(.tags(.all))
        return tags.compactMap(TagEntity.init)
    }

    static func getByID(context: ModelContext, id: String) throws -> TagEntity? {
        let persistentID = try PersistentIdentifier(base64Encoded: id)
        guard let tag = try context.fetchFirst(
            .tags(.idIs(persistentID))
        ) else {
            return nil
        }
        return TagEntity(tag)
    }

    static func getByName(
        context: ModelContext,
        name: String,
        type: TagType
    ) throws -> TagEntity? {
        let tag = try context.fetchFirst(
            .tags(.nameIs(name, type: type))
        )
        return tag.flatMap(TagEntity.init)
    }

    static func findDuplicates(
        context: ModelContext,
        tags: [TagEntity]
    ) throws -> [TagEntity] {
        let models: [Tag] = try tags.compactMap { entity in
            let id = try PersistentIdentifier(base64Encoded: entity.id)
            return try context.fetchFirst(
                .tags(.idIs(id))
            )
        }
        let duplicates = Dictionary(grouping: models) { tag in
            tag.typeID + tag.name
        }
        .compactMap { _, values -> Tag? in
            guard values.count > 1 else {
                return nil
            }
            return values.first
        }
        return duplicates.compactMap(TagEntity.init)
    }

    static func hasDuplicates(context: ModelContext) throws -> Bool {
        let tags = try getAll(context: context)
        let duplicates = try findDuplicates(context: context, tags: tags)
        return !duplicates.isEmpty
    }

    static func mergeDuplicates(
        context: ModelContext,
        tags: [TagEntity]
    ) throws {
        let models: [Tag] = try tags.compactMap { entity in
            let id = try PersistentIdentifier(base64Encoded: entity.id)
            return try context.fetchFirst(
                .tags(.idIs(id))
            )
        }
        guard let parent = models.first else {
            return
        }
        let children = models.filter {
            $0.id != parent.id
        }
        for item in children.flatMap({ $0.items ?? [] }) {
            var tags = item.tags ?? []
            tags.append(parent)
            item.modify(tags: tags)
        }
        try children.compactMap(TagEntity.init).forEach { child in
            try delete(context: context, tag: child)
        }
    }

    static func resolveDuplicates(
        context: ModelContext,
        tags: [TagEntity]
    ) throws {
        let models: [Tag] = try tags.compactMap { entity in
            let id = try PersistentIdentifier(base64Encoded: entity.id)
            return try context.fetchFirst(
                .tags(.idIs(id))
            )
        }
        for model in models {
            let duplicates = try context.fetch(
                .tags(.isSameWith(model))
            )
            try mergeDuplicates(
                context: context,
                tags: duplicates.compactMap(TagEntity.init)
            )
        }
    }

    static func delete(context: ModelContext, tag: TagEntity) throws {
        let id = try PersistentIdentifier(base64Encoded: tag.id)
        guard let model = try context.fetchFirst(
            .tags(.idIs(id))
        ) else {
            throw TagError.tagNotFound
        }
        model.delete()
    }

    static func deleteAll(context: ModelContext) throws {
        let tags = try context.fetch(FetchDescriptor<Tag>())
        tags.forEach { tag in
            tag.delete()
        }
    }
}
