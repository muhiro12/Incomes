//
//  ItemEntity.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/22.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct ItemEntity: AppEntity, ModelBridgeable {
    static let defaultQuery = ItemEntityQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(
            name: .init("Item", table: "AppIntents"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) Items", table: "AppIntents")
        )
    }

    var displayRepresentation: DisplayRepresentation {
        .init(
            title: .init("\(date.stringValue(.yyyyMMMd)) \(content)", table: "AppIntents"),
            subtitle: .init("Income: \(income.asCurrency), Outgo: \(outgo.asCurrency)", table: "AppIntents"),
            image: .init(
                systemName: profit.isPlus ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
            ),
            synonyms: [
                .init("\(content)", table: "AppIntents")
            ]
        )
    }

    let id: String
    let date: Date
    let content: String
    let income: Decimal
    let outgo: Decimal
    let profit: Decimal
    let balance: Decimal
    let category: String?

    init(_ item: Item) throws {
        id = try item.id.base64Encoded()
        date = item.localDate
        content = item.content
        income = item.income
        outgo = item.outgo
        profit = item.profit
        balance = item.balance
        category = item.category?.displayName
    }
}

extension ItemEntity {
    var persistentIdentifier: Item.ID? { try? .init(base64Encoded: id) }
}

extension ItemEntity {
    typealias Model = Item

    init?(_ model: Item) {
        try? self.init(model)
    }
}
