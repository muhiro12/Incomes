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

    static func fetch(_ context: NSManagedObjectContext,
                      format: String,
                      keys: [Any]?,
                      completion: ((ListItems) -> Void)? = nil) {
        DataStore.fetch(context,
                        format: format,
                        keys: keys,
                        completion: completion)
    }

    // MARK: - Create

    static func create(_ context: NSManagedObjectContext,
                       item: ListItem,
                       repeatCount: Int = .one,
                       completion: (() -> Void)? = nil) {
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
        DataStore.saveAll(context,
                          items: ListItems(key: repeatId.string, value: recurringItems),
                          repeatId: repeatId,
                          completion: completion)
    }

    // MARK: - Update

    static func update(_ context: NSManagedObjectContext,
                       item: ListItem,
                       completion: (() -> Void)? = nil) {
        DataStore.save(context,
                       item: item,
                       completion: completion)
    }

    static func updateRecurringItem(_ context: NSManagedObjectContext,
                                    format: String,
                                    keys: [Any]?,
                                    oldItem: ListItem,
                                    newItem: ListItem,
                                    completion: (() -> Void)? = nil) {
        fetch(context,
              format: format,
              keys: keys) { items in
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
                DataStore.saveAll(context,
                                  items: newItems,
                                  repeatId: repeatId,
                                  completion: completion)
        }
    }

    static func updateAllFollowingItems(_ context: NSManagedObjectContext,
                                        oldItem: ListItem,
                                        newItem: ListItem,
                                        completion: (() -> Void)? = nil) {
        guard let repeatId = oldItem.original?.repeatId else {
            return
        }
        updateRecurringItem(context,
                            format: "(repeatId = %@) AND (date >= %@)",
                            keys: [repeatId, oldItem.date],
                            oldItem: oldItem,
                            newItem: newItem,
                            completion: completion)
    }

    static func updateAllRecurringItems(_ context: NSManagedObjectContext,
                                        oldItem: ListItem,
                                        newItem: ListItem,
                                        completion: (() -> Void)? = nil) {
        guard let repeatId = oldItem.original?.repeatId else {
            return
        }
        updateRecurringItem(context,
                            format: "repeatId = %@",
                            keys: [repeatId],
                            oldItem: oldItem,
                            newItem: newItem,
                            completion: completion)
    }

    // MARK: - Delete

    static func delete(_ context: NSManagedObjectContext,
                       item: ListItem,
                       completion: (() -> Void)? = nil) {
        DataStore.delete(context,
                         item: item,
                         completion: completion)
    }
}
