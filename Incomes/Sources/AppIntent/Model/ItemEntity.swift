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
}

// MARK: - ModelBridgeable

extension ItemEntity: ModelBridgeable {
    typealias Model = Item

    init?(_ model: Item) {
        guard let encodedID = try? model.id.base64Encoded() else {
            return nil
        }
        id = encodedID
        date = model.localDate
        content = model.content
        income = model.income
        outgo = model.outgo
        profit = model.profit
        balance = model.balance
    }
}
