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

    func itemsCount(predicate: Predicate<Item>? = nil) throws -> Int {
        try context.fetchCount(.init(predicate: predicate))
    }

    // MARK: - Create

    func create(date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String,
                repeatCount: Int = .one) throws {
        var items = [Item]()

        let repeatID = UUID()

        let item = try Item.create(
            context: context,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            group: group,
            repeatID: repeatID
        )
        items.append(item)

        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let repeatingDate = Calendar.utc.date(byAdding: .month,
                                                        value: index,
                                                        to: date) else {
                assertionFailure()
                return
            }
            let item = try Item.create(
                context: context,
                date: repeatingDate,
                content: content,
                income: income,
                outgo: outgo,
                group: group,
                repeatID: repeatID
            )
            items.append(item)
        }

        items.forEach(context.insert)
        try context.save()

        try calculator.calculate(for: items)
    }

    // MARK: - Update

    func update(item: Item,
                date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String) throws {
        try item.modify(date: date,
                        content: content,
                        income: income,
                        outgo: outgo,
                        group: group,
                        repeatID: .init())
        try calculator.calculate(for: [item])
    }

    func updateForFutureItems(item: Item,
                              date: Date,
                              content: String,
                              income: Decimal,
                              outgo: Decimal,
                              group: String) throws {
        try updateForRepeatingItems(item: item,
                                    date: date,
                                    content: content,
                                    income: income,
                                    outgo: outgo,
                                    group: group,
                                    predicate: Item.predicate(repeatIDIs: item.repeatID, dateIsAfter: item.date))
    }

    func updateForAllItems(item: Item,
                           date: Date,
                           content: String,
                           income: Decimal,
                           outgo: Decimal,
                           group: String) throws {
        try updateForRepeatingItems(item: item,
                                    date: date,
                                    content: content,
                                    income: income,
                                    outgo: outgo,
                                    group: group,
                                    predicate: Item.predicate(repeatIDIs: item.repeatID))
    }

    // MARK: - Delete

    func delete(items: [Item]) throws {
        try items.forEach {
            try $0.delete()
        }
        try calculator.calculate(for: items)
    }

    func deleteAll() throws {
        try delete(items: try context.fetch(.init()))
    }

    // MARK: - Calculate balance

    func recalculate() throws {
        try calculator.calculateAll()
    }
}

private extension ItemService {
    func updateForRepeatingItems(item: Item,
                                 date: Date,
                                 content: String,
                                 income: Decimal,
                                 outgo: Decimal,
                                 group: String,
                                 predicate: Predicate<Item>) throws {
        let components = Calendar.utc.dateComponents([.year, .month, .day],
                                                     from: item.date,
                                                     to: date)

        let repeatID = UUID()
        let items = try context.fetch(.init(predicate: predicate, sortBy: Item.sortDescriptors()))
        try items.forEach {
            guard let newDate = Calendar.utc.date(byAdding: components, to: $0.date) else {
                assertionFailure()
                return
            }
            try $0.modify(
                date: newDate,
                content: content,
                income: income,
                outgo: outgo,
                group: group,
                repeatID: repeatID
            )
        }

        try context.save()
        try calculator.calculate(for: items)
    }
}
