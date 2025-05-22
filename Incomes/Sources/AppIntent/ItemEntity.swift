//
//  ItemEntity.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/22.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct ItemEntity: AppEntity {
    static let defaultQuery = ItemEntityQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(
            name: "Item",
            numericFormat: "\(placeholder: .int) Items"
        )
    }

    var displayRepresentation: DisplayRepresentation {
        .init(
            title: "\(content)",
            subtitle: "\(balance.asCurrency)"
        )
    }

    let id: String
    let date: Date
    let content: String
    let income: Decimal
    let outgo: Decimal
    let profit: Decimal
    let balance: Decimal

    init(_ item: Item) throws {
        id = try JSONEncoder().encode(item.id).base64EncodedString()
        date = item.localDate
        content = item.content
        income = item.income
        outgo = item.outgo
        profit = item.profit
        balance = item.balance
    }
}

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
