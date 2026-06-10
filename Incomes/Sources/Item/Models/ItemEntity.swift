//
//  ItemEntity.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/22.
//

import AppIntents
import SwiftData

@Observable
final class ItemEntity: AppEntity {
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
                systemName: netIncome.isPlus ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
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
    let netIncome: Decimal

    private init(
        id: String,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        netIncome: Decimal
    ) {
        self.id = id
        self.date = date
        self.content = content
        self.income = income
        self.outgo = outgo
        self.netIncome = netIncome
    }
}

extension ItemEntity {
    convenience init?(_ model: Item) {
        guard let encodedID = try? PersistentIdentifierCoder.encode(model.id) else {
            return nil
        }
        self.init(
            id: encodedID,
            date: model.localDate,
            content: model.content,
            income: model.income,
            outgo: model.outgo,
            netIncome: model.netIncome
        )
    }

    static func make(from model: Item) throws -> ItemEntity {
        guard let entity = ItemEntity(model) else {
            throw ItemError.entityConversionFailed
        }
        return entity
    }

    static func make(from model: Item?) throws -> ItemEntity? {
        try model.map { item in
            try make(from: item)
        }
    }

    static func make(from models: [Item]) throws -> [ItemEntity] {
        try models.map { item in
            try make(from: item)
        }
    }
}

extension ItemEntity {
    var isNetIncomePositive: Bool {
        netIncome.isPlus
    }

    func model(in context: ModelContext) throws -> Item {
        guard let model = try ItemQueryOperations.item(
            context: context,
            encodedIdentifier: id
        ) else {
            throw ItemError.itemNotFound
        }
        return model
    }
}
