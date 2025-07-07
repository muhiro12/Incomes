//
//  ItemEntityQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct ItemEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor func entities(for identifiers: [ItemEntity.ID]) throws -> [ItemEntity] {
        try modelContainer.mainContext.fetch(
            .items(
                .idsAre(
                    identifiers.map {
                        try .init(base64Encoded: $0)
                    }
                )
            )
        )
        .compactMap(ItemEntity.init)
    }

    @MainActor func entities(matching string: String) throws -> [ItemEntity] {
        try modelContainer.mainContext.fetch(
            .items(.contentContains(string))
        )
        .compactMap(ItemEntity.init)
    }

    @MainActor func suggestedEntities() throws -> [ItemEntity] {
        try modelContainer.mainContext.fetch(
            .items(.dateIsSameMonthAs(.now))
        )
        .compactMap(ItemEntity.init)
    }
}
