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
    private let fetcher: ItemFetcher
    private let adder: ItemAdder
    private let updater: ItemUpdater
    private let deleter: ItemDeleter
    private let calculator: ItemBalanceCalculator

    init(context: ModelContext) {
        self.fetcher = ItemFetcher(context: context)
        self.adder = ItemAdder(context: context)
        self.updater = ItemUpdater(context: context)
        self.deleter = ItemDeleter(context: context)
        self.calculator = ItemBalanceCalculator(context: context)
    }

    // MARK: - Fetch

    func items(predicate: Predicate<Item>? = nil) throws -> [Item] {
        try fetcher.fetch(predicate: predicate)
    }

    func itemsCount(predicate: Predicate<Item>? = nil) throws -> Int {
        try fetcher.fetchCount(predicate: predicate)
    }

    // MARK: - Create

    func create(date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String,
                repeatCount: Int = .one) throws {
        try adder.add(date: date,
                      content: content,
                      income: income,
                      outgo: outgo,
                      group: group,
                      repeatCount: repeatCount)
    }

    // MARK: - Update

    func update(item: Item, // swiftlint:disable:this function_parameter_count
                date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String) throws {
        try updater.update(item: item,
                           date: date,
                           content: content,
                           income: income,
                           outgo: outgo,
                           group: group)
    }

    func updateForFutureItems(item: Item, // swiftlint:disable:this function_parameter_count
                              date: Date,
                              content: String,
                              income: Decimal,
                              outgo: Decimal,
                              group: String) throws {
        try updater.updateForFutureItems(item: item,
                                         date: date,
                                         content: content,
                                         income: income,
                                         outgo: outgo,
                                         group: group)
    }

    func updateForAllItems(item: Item, // swiftlint:disable:this function_parameter_count
                           date: Date,
                           content: String,
                           income: Decimal,
                           outgo: Decimal,
                           group: String) throws {
        try updater.updateForAllItems(item: item,
                                      date: date,
                                      content: content,
                                      income: income,
                                      outgo: outgo,
                                      group: group)
    }

    // MARK: - Delete

    func delete(items: [Item]) throws {
        try deleter.delete(items: items)
    }

    func deleteAll() throws {
        try deleter.deleteAll()
    }

    // MARK: - Calculate balance

    func calculate(for items: [Item]) throws {
        try calculator.calculate(for: items)
    }

    func recalculate() throws {
        try calculator.calculateAll()
    }
}
