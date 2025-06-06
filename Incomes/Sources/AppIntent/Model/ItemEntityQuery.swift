//
//  ItemEntityQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct ItemEntityQuery: EntityStringQuery, @unchecked Sendable {
    @Dependency private var itemService: ItemService

    func entities(for identifiers: [ItemEntity.ID]) throws -> [ItemEntity] {
        try itemService.items(
            .items(.idsAre(identifiers.map { try .init(base64Encoded: $0) }))
        )
        .map {
            try .init($0)
        }
    }

    func entities(matching string: String) throws -> [ItemEntity] {
        try itemService.items(.items(.contentContains(string))).map {
            try .init($0)
        }
    }

    func suggestedEntities() throws -> [ItemEntity] {
        try itemService.items(.items(.dateIsSameMonthAs(.now))).map {
            try .init($0)
        }
    }
}
