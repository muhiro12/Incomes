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
                                                   to: item.date.unwrapped) else {
                assertionFailure()
                return
            }
            let recurringItem = Item(date: date,
                                     content: item.content.unwrapped,
                                     income: item.income.unwrappedDecimal,
                                     outgo: item.outgo.unwrappedDecimal,
                                     group: item.group.unwrapped,
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
                                                             from: oldItem.date.unwrapped,
                                                             to: newItem.date.unwrapped)
            guard let newDate = Calendar.current.date(byAdding: components,
                                                      to: item.date.unwrapped) else {
                assertionFailure()
                return nil
            }
            return Item(date: newDate,
                        content: newItem.content.unwrapped,
                        income: newItem.income.unwrappedDecimal,
                        outgo: newItem.outgo.unwrappedDecimal,
                        group: newItem.group.unwrapped,
                        repeatID: UUID())
        }
        let repeatId = UUID()
        let newItems = newItemList

        try DataStore.saveAll(context, items: newItems, repeatId: repeatId)
    }

    static func saveForFutureItems(_ context: NSManagedObjectContext,
                                   oldItem: Item,
                                   newItem: Item) async throws {
        guard let repeatId = oldItem.repeatId else {
            assertionFailure()
            return
        }
        try await saveForRepeatingItems(context,
                                        format: "(repeatId = %@) AND (date >= %@)",
                                        keys: [repeatId, oldItem.date.unwrapped],
                                        oldItem: oldItem,
                                        newItem: newItem)
    }

    static func saveForAllItems(_ context: NSManagedObjectContext,
                                oldItem: Item,
                                newItem: Item) async throws {
        guard let repeatId = oldItem.repeatId else {
            assertionFailure()
            return
        }
        try await saveForRepeatingItems(context,
                                        format: "repeatId = %@",
                                        keys: [repeatId],
                                        oldItem: oldItem,
                                        newItem: newItem)
    }

    // MARK: - Delete

    static func delete(_ context: NSManagedObjectContext, item: Item) {
        DataStore.delete(context, item: item)
    }
}
