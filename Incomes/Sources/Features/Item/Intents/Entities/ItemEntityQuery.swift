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
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            encodedIdentifiers: identifiers
        )
        return try ItemEntity.make(from: items)
    }

    @MainActor
    func entities(matching string: String) throws -> [ItemEntity] {
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            matchingContent: string
        )
        return try ItemEntity.make(from: items)
    }

    @MainActor
    func suggestedEntities() throws -> [ItemEntity] {
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: .now
        )
        return try ItemEntity.make(from: items)
    }
}
