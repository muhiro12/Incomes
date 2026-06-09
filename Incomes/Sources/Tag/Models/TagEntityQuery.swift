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
        try TagQueryOperations.getByIDs(
            context: modelContainer.mainContext,
            ids: identifiers
        )
        .map(TagEntity.make)
    }

    @MainActor
    func entities(matching string: String) throws -> [TagEntity] {
        try TagQueryOperations.representativeTags(
            context: modelContainer.mainContext,
            matching: string
        )
        .map(TagEntity.make)
    }

    @MainActor
    func suggestedEntities() throws -> [TagEntity] {
        try TagQueryOperations.representativeTags(
            context: modelContainer.mainContext
        )
        .map(TagEntity.make)
    }
}
