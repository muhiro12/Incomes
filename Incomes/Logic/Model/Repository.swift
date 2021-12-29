//
//  Repository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct Repository {

    // MARK: - Fetch

    static func listItems(_ context: NSManagedObjectContext,
                          format: String,
                          keys: [Any]?) async throws -> [Item] {
        try await DataStore.listItems(context, format: format, keys: keys)
    }

    // MARK: - Create

    static func create(_ context: NSManagedObjectContext,
                       item: Item,
                       repeatCount: Int = .one) throws {
        var recurringItems: [Item] = []
        for index in 0..<repeatCount {
            guard let date = Calendar.current.date(byAdding: .month,
                                                   value: index,
                                                   to: item.date) else {
                assertionFailure()
                return
            }
            let recurringItem = Item(context: context,
                                     date: date,
                                     content: item.content,
                                     income: item.income.decimalValue,
                                     outgo: item.outgo.decimalValue,
                                     group: item.group,
                                     repeatID: UUID())
            recurringItems.append(recurringItem)
        }
        let repeatId = repeatCount > .one ? UUID() : nil
        try DataStore.saveAll(context,
                              items: recurringItems,
                              repeatId: repeatId)
    }

    // MARK: - Save

    static func save(_ context: NSManagedObjectContext, item: Item) throws {
        try DataStore.save(context, item: item)
    }

    static func saveForRepeatingItems(_ context: NSManagedObjectContext,
                                      format: String,
                                      keys: [Any]?,
                                      oldItem: Item,
                                      newItem: Item) async throws {
        let items = try await listItems(context, format: format, keys: keys)
        let newItemList: [Item] = items.compactMap { item in
            let components = Calendar.current.dateComponents([.year, .month, .day],
                                                             from: oldItem.date,
                                                             to: newItem.date)
            guard let newDate = Calendar.current.date(byAdding: components,
                                                      to: item.date) else {
                assertionFailure()
                return nil
            }
            return Item(context: context,
                        date: newDate,
                        content: newItem.content,
                        income: newItem.income.decimalValue,
                        outgo: newItem.outgo.decimalValue,
                        group: newItem.group,
                        repeatID: UUID())
        }
        let repeatId = UUID()
        let newItems = newItemList

        try DataStore.saveAll(context, items: newItems, repeatId: repeatId)
    }

    static func saveForFutureItems(_ context: NSManagedObjectContext,
                                   oldItem: Item,
                                   newItem: Item) async throws {
        try await saveForRepeatingItems(context,
                                        format: "(repeatId = %@) AND (date >= %@)",
                                        keys: [oldItem.repeatId, oldItem.date],
                                        oldItem: oldItem,
                                        newItem: newItem)
    }

    static func saveForAllItems(_ context: NSManagedObjectContext,
                                oldItem: Item,
                                newItem: Item) async throws {
        try await saveForRepeatingItems(context,
                                        format: "repeatId = %@",
                                        keys: [oldItem.repeatId],
                                        oldItem: oldItem,
                                        newItem: newItem)
    }

    // MARK: - Delete

    static func delete(_ context: NSManagedObjectContext, item: Item) {
        DataStore.delete(context, item: item)
    }
}
