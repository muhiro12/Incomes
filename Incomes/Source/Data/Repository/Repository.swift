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
                          keys: [Any]?) async throws -> ListItems {
        try await DataStore.listItems(context, format: format, keys: keys)
    }

    // MARK: - Create

    static func create(_ context: NSManagedObjectContext,
                       item: ListItem,
                       repeatCount: Int = .one) throws {
        var recurringItems: [ListItem] = []
        for index in 0..<repeatCount {
            guard let date = Calendar.current.date(byAdding: .month,
                                                   value: index,
                                                   to: item.date) else {
                return
            }
            let recurringItem = ListItem(date: date,
                                         content: item.content,
                                         group: item.group,
                                         income: item.income,
                                         expenditure: item.expenditure)
            recurringItems.append(recurringItem)
        }
        let repeatId = repeatCount > .one ? UUID() : nil
        try DataStore.saveAll(context,
                              items: ListItems(key: repeatId.string, value: recurringItems),
                              repeatId: repeatId)
    }

    // MARK: - Save

    static func save(_ context: NSManagedObjectContext, item: ListItem) throws {
        try DataStore.save(context, item: item)
    }

    static func saveForRepeatingItems(_ context: NSManagedObjectContext,
                                      format: String,
                                      keys: [Any]?,
                                      oldItem: ListItem,
                                      newItem: ListItem) async throws {
        let items = try await listItems(context, format: format, keys: keys)
        let newItemList: [ListItem] = items.value.compactMap { item in
            let components = Calendar.current.dateComponents([.year, .month, .day],
                                                             from: oldItem.date,
                                                             to: newItem.date)
            guard let newDate = Calendar.current.date(byAdding: components,
                                                      to: item.date) else {
                return nil
            }
            return ListItem(date: newDate,
                            content: newItem.content,
                            group: newItem.group,
                            income: newItem.income,
                            expenditure: newItem.expenditure,
                            original: item.original)
        }
        let repeatId = UUID()
        let newItems = ListItems(key: repeatId.description,
                                 value: newItemList)
        try DataStore.saveAll(context, items: newItems, repeatId: repeatId)
    }

    static func saveForFutureItems(_ context: NSManagedObjectContext,
                                   oldItem: ListItem,
                                   newItem: ListItem) async throws {
        guard let repeatId = oldItem.original?.repeatId else {
            return
        }
        try await saveForRepeatingItems(context,
                                        format: "(repeatId = %@) AND (date >= %@)",
                                        keys: [repeatId, oldItem.date],
                                        oldItem: oldItem,
                                        newItem: newItem)
    }

    static func saveForAllItems(_ context: NSManagedObjectContext,
                                oldItem: ListItem,
                                newItem: ListItem) async throws {
        guard let repeatId = oldItem.original?.repeatId else {
            return
        }
        try await saveForRepeatingItems(context,
                                        format: "repeatId = %@",
                                        keys: [repeatId],
                                        oldItem: oldItem,
                                        newItem: newItem)
    }

    // MARK: - Delete

    static func delete(_ context: NSManagedObjectContext, item: ListItem) {
        DataStore.delete(context, item: item)
    }
}
