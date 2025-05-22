//
//  ItemEntity.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/22.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

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
