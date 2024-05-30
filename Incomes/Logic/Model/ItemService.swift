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
    private let context: ModelContext
    private let calculator: ItemBalanceCalculator

    init(context: ModelContext) {
        self.context = context
        self.calculator = ItemBalanceCalculator(context: context)
    }

    // MARK: - Fetch

    func items(predicate: Predicate<Item>? = nil) throws -> [Item] {
        try context.fetch(.init(predicate: predicate, sortBy: Item.sortDescriptors()))
    }

    func itemsCount(predicate: Predicate<Item>? = nil) throws -> Int {
        try context.fetchCount(.init(predicate: predicate))
    }

    // MARK: - Create

    func factory(date: Date, // swiftlint:disable:this function_parameter_count
                 content: String,
                 income: Decimal,
                 outgo: Decimal,
                 group: String,
                 repeatID: UUID) throws -> Item {
        let item = Item()
        context.insert(item)

        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: repeatID)
        item.set(tags: try tags(date: date, content: content, group: group))

        return item
    }

    func create(date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String,
                repeatCount: Int = .one) throws {
        var items = [Item]()

        let repeatID = UUID()

        let item = try factory(
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
            let item = try factory(
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

    private func update(items: [Item]) throws {
        try context.save()
        try calculator.calculate(for: items)
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
        item.set(tags: try tags(date: date, content: content, group: group))
        try update(items: [item])
    }

    private func updateForRepeatingItems(item: Item, // swiftlint:disable:this function_parameter_count
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
            $0.set(date: newDate,
                   content: content,
                   income: income,
                   outgo: outgo,
                   group: group,
                   repeatID: repeatID)
            item.set(tags: try tags(date: newDate, content: content, group: group))
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
        items.forEach(context.delete)
        try context.save()
        try calculator.calculate(for: items)
    }

    func deleteAll() throws {
        try delete(items: try context.fetch(.init()))
    }

    // MARK: - Calculate balance

    func calculate(for items: [Item]) throws {
        try calculator.calculate(for: items)
    }

    func recalculate() throws {
        try calculator.calculateAll()
    }

    // MARK: - Tag

    private func tagFactory(_ name: String, for type: Tag.TagType) throws -> Tag {
        var tags = try context.fetch(
            .init(predicate: Tag.predicate(name: name, type: type), sortBy: Tag.sortDescriptors())
        )
        guard let tag = tags.popLast() else {
            let tag = Tag()
            context.insert(tag)
            tag.set(name: name, typeID: type.rawValue)
            return tag
        }
        tags.forEach(context.delete)
        try context.save()
        return tag
    }

    private func tags(date: Date, content: String, group: String) throws -> [Tag] {
        [try tagFactory(Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy), for: .year),
         try tagFactory(Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM), for: .yearMonth),
         try tagFactory(content, for: .content),
         try tagFactory(group, for: .category)]
    }
}
