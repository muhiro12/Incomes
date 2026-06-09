//
//  ItemEntityQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//

import AppIntents
import SwiftData

struct ItemEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func entities(for identifiers: [ItemEntity.ID]) throws -> [ItemEntity] {
        try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            encodedIdentifiers: identifiers
        )
        .compactMap(ItemEntity.init)
    }

    @MainActor
    func entities(matching string: String) throws -> [ItemEntity] {
        try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            matchingContent: string
        )
        .compactMap(ItemEntity.init)
    }

    @MainActor
    func suggestedEntities() throws -> [ItemEntity] {
        try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: .now
        )
        .compactMap(ItemEntity.init)
    }
}
