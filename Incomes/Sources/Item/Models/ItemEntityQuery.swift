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
        .map(ItemEntity.make)
    }

    @MainActor
    func entities(matching string: String) throws -> [ItemEntity] {
        try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            matchingContent: string
        )
        .map(ItemEntity.make)
    }

    @MainActor
    func suggestedEntities() throws -> [ItemEntity] {
        try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: .now
        )
        .map(ItemEntity.make)
    }
}
