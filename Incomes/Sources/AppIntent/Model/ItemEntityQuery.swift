//
//  ItemEntityQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct ItemEntityQuery: EntityStringQuery, @unchecked Sendable {
    @Dependency private var itemService: ItemService

    func entities(for identifiers: [ItemEntity.ID]) throws -> [ItemEntity] {
        try itemService.items(
            .items(
                .idsAre(
                    identifiers.map {
                        guard let data = Data(base64Encoded: $0) else {
                            throw DebugError.default
                        }
                        return try JSONDecoder().decode(PersistentIdentifier.self, from: data)
                    }
                )
            )
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
