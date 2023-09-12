//
//  ItemService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct ItemService {
    private let repository: any Repository<Item>
    private let factory: ItemFactory
    private let calculator: BalanceCalculator

    init(context: ModelContext) {
        self.repository = ItemRepository(context: context)
        self.factory = ItemFactory()
        self.calculator = BalanceCalculator(context: context)
    }

    // MARK: - Fetch

    func item(predicate: Predicate<Item>? = nil) throws -> Item? {
        try repository.fetch(predicate: predicate)
    }

    func items(predicate: Predicate<Item>? = nil) throws -> [Item] {
        try repository.fetchList(predicate: predicate)
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

        let item = factory(date: date,
                           content: content,
                           income: income,
                           outgo: outgo,
                           group: group,
                           repeatID: repeatID)
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
            let item = factory(date: repeatingDate,
                               content: content,
                               income: income,
                               outgo: outgo,
                               group: group,
                               repeatID: repeatID)
            items.append(item)
        }

        try repository.addList(items)
        try calculate(for: items)
    }

    // MARK: - Update

    func update(items: [Item]) throws {
        try repository.updateList(items)
        try calculate(for: items)
    }

    func update(item: Item, // swiftlint:disable:this function_parameter_count
                date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String) throws {
        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: UUID())
        try update(items: [item])
    }

    func updateForRepeatingItems(item: Item, // swiftlint:disable:this function_parameter_count
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
        let items = try items(predicate: predicate)
        items.forEach {
            guard let newDate = Calendar.utc.date(byAdding: components, to: $0.date) else {
                assertionFailure()
                return
            }
            $0.set(date: newDate,
                   content: content,
                   income: income,
                   outgo: outgo,
                   group: group,
                   repeatID: repeatID)
        }

        try update(items: items)
    }

    func updateForFutureItems(item: Item, // swiftlint:disable:this function_parameter_count
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

    func updateForAllItems(item: Item, // swiftlint:disable:this function_parameter_count
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
        try repository.deleteList(items)
        try calculate(for: items)
    }

    func deleteAll() throws {
        try delete(items: items())
    }

    // MARK: - Calculate balance

    func calculate(for items: [Item]) throws {
        if let date = items.map({ $0.date }).min() {
            try calculator.calculate(after: date)
        } else {
            try recalculate()
        }
    }

    func recalculate() throws {
        try calculator.calculateAll()
    }
}

// MARK: - Utilitiy

extension ItemService {
    static func groupByYear(items: [Item]) -> [SectionedItems<Date>] {
        Dictionary(grouping: items) {
            Calendar.utc.startOfYear(for: $0.date)
        }
        .map {
            SectionedItems(section: $0.key, items: $0.value)
        }
        .sorted()
        .reversed()
    }

    static func groupByMonth(items: [Item]) -> [SectionedItems<Date>] {
        Dictionary(grouping: items) {
            Calendar.utc.startOfMonth(for: $0.date)
        }
        .map {
            SectionedItems(section: $0.key, items: $0.value)
        }
        .sorted()
        .reversed()
    }

    static func groupByContent(items: [Item]) -> [SectionedItems<String>] {
        Dictionary(grouping: items) {
            $0.content
        }
        .map {
            SectionedItems(section: $0.key, items: $0.value)
        }
        .sorted()
    }
}
