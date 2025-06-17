//
//  ItemService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

@Observable
final class ItemService {
    private let context: ModelContext
    private let calculator: BalanceCalculator

    init(context: ModelContext) {
        self.context = context
        self.calculator = .init(context: context)
    }

    // MARK: - Fetch

    func item(_ descriptor: FetchDescriptor<Item> = .items(.all)) throws -> Item? {
        try context.fetchFirst(descriptor)
    }

    func items(_ descriptor: FetchDescriptor<Item> = .items(.all)) throws -> [Item] {
        try context.fetch(descriptor)
    }

    func model(of entity: ItemEntity) throws -> Item {
        guard let model = try item(.items(.idIs(.init(base64Encoded: entity.id)))) else {
            throw DebugError.default
        }
        return model
    }

    func itemsCount(_ descriptor: FetchDescriptor<Item> = .items(.all)) throws -> Int {
        try context.fetchCount(descriptor)
    }

    // MARK: - Update

    func update(item: Item,
                date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                category: String) throws {
        try item.modify(date: date,
                        content: content,
                        income: income,
                        outgo: outgo,
                        category: category,
                        repeatID: .init())
        try calculator.calculate(for: [item])
    }

    func updateForFutureItems(item: Item,
                              date: Date,
                              content: String,
                              income: Decimal,
                              outgo: Decimal,
                              category: String) throws {
        try updateForRepeatingItems(item: item,
                                    date: date,
                                    content: content,
                                    income: income,
                                    outgo: outgo,
                                    category: category,
                                    descriptor: .items(.repeatIDAndDateIsAfter(repeatID: item.repeatID, date: item.localDate)))
    }

    func updateForAllItems(item: Item,
                           date: Date,
                           content: String,
                           income: Decimal,
                           outgo: Decimal,
                           category: String) throws {
        try updateForRepeatingItems(item: item,
                                    date: date,
                                    content: content,
                                    income: income,
                                    outgo: outgo,
                                    category: category,
                                    descriptor: .items(.repeatIDIs(item.repeatID)))
    }

    // MARK: - Delete

    func delete(items: [Item]) throws {
        items.forEach {
            $0.delete()
        }
        try calculator.calculate(for: items)
    }

    func deleteAll() throws {
        try delete(items: context.fetch(.init()))
    }

    // MARK: - Calculate balance

    func recalculate(after date: Date) throws {
        try calculator.calculate(after: date)
    }
}

private extension ItemService {
    func updateForRepeatingItems(item: Item,
                                 date: Date,
                                 content: String,
                                 income: Decimal,
                                 outgo: Decimal,
                                 category: String,
                                 descriptor: FetchDescriptor<Item>) throws {
        let components = Calendar.current.dateComponents([.year, .month, .day],
                                                         from: item.localDate,
                                                         to: date)

        let repeatID = UUID()
        let items = try context.fetch(descriptor)
        try items.forEach {
            guard let newDate = Calendar.current.date(byAdding: components, to: $0.localDate) else {
                assertionFailure()
                return
            }
            try $0.modify(
                date: newDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                repeatID: repeatID
            )
        }

        try calculator.calculate(for: items)
    }
}
