import Foundation
import SwiftData

enum TagIntentGetValueSupport {
    static func duplicateTagEntities(context: ModelContext) throws -> [TagEntity] {
        let tags = try TagQueryOperations.duplicateTags(
            context: context
        )
        return try TagIntentEntitySupport.entities(from: tags)
    }

    static func orphanTagEntities(context: ModelContext) throws -> [TagEntity] {
        let tags = try TagQueryOperations.orphanTags(
            context: context
        )
        return try TagIntentEntitySupport.entities(from: tags)
    }

    static func itemEntities(
        for tag: TagEntity,
        context: ModelContext
    ) throws -> [ItemEntity] {
        let model = try tag.model(in: context)
        let items = TagQueryOperations.items(for: model)
        return try ItemIntentEntitySupport.entities(from: items)
    }

    static func date(
        for tag: TagEntity,
        context: ModelContext
    ) throws -> Date? {
        let model = try tag.model(in: context)
        return TagQueryOperations.date(for: model)
    }

    static func yearStrings(
        for tag: TagEntity,
        context: ModelContext
    ) throws -> [String] {
        let model = try tag.model(in: context)
        return TagQueryOperations.yearStrings(for: model)
    }

    static func categoryFacetNames(context: ModelContext) throws -> [String] {
        try CategoryFacetOperations.facets(
            context: context
        )
        .map(\.displayName)
    }

    static func filteredCategoryFacetNames(
        context: ModelContext,
        query: String
    ) throws -> [String] {
        try CategoryFacetOperations.filteredFacets(
            context: context,
            query: query
        )
        .map(\.displayName)
    }
}
