//
//  TagEntityQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/24.
//

import AppIntents
import SwiftData

struct TagEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func entities(for identifiers: [TagEntity.ID]) throws -> [TagEntity] {
        try identifiers.compactMap { id in
            guard let tag = try TagOperations.getByID(
                context: modelContainer.mainContext,
                id: id
            ) else {
                return nil
            }
            return .init(tag)
        }
    }

    @MainActor
    func entities(matching string: String) throws -> [TagEntity] {
        let tags = try TagOperations.getAll(context: modelContainer.mainContext)
        return [
            TagType.year,
            .yearMonth,
            .content,
            .category
        ]
        .compactMap { type in
            guard let tag = tags.first(
                where: { item in
                    item.type == type
                        && (
                            TagTextSupport.matchesStoredName(
                                item.name,
                                query: string
                            )
                            || TagTextSupport.matchesDisplayName(
                                name: item.name,
                                type: item.type,
                                query: string
                            )
                        )
                }
            ) else {
                return nil
            }
            return .init(tag)
        }
    }

    @MainActor
    func suggestedEntities() throws -> [TagEntity] {
        let tags = try TagOperations.getAll(context: modelContainer.mainContext)
        return [
            TagType.year,
            .yearMonth,
            .content,
            .category
        ]
        .compactMap { type in
            guard let tag = tags.first(
                where: { item in
                    item.type == type
                }
            ) else {
                return nil
            }
            return .init(tag)
        }
    }
}
