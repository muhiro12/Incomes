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
        let repeatId = UUID()
        DataStore.saveAll(context,
                          items: ListItems(key: repeatId.description, value: recurringItems),
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

    static func updateAllRecurringItem(_ context: NSManagedObjectContext,
                                       oldItem: ListItem,
                                       newItem: ListItem,
                                       completion: (() -> Void)? = nil) {
        guard let repeatId = newItem.original?.repeatId else {
            completion?()
            return
        }
        DataStore.fetch(context,
                        format: "repeatId = %@",
                        key: repeatId.description) { items in
                            let newItemList: [ListItem] = items.value.compactMap { item in
                                let difference = Calendar.current.dateComponents([.year, .month, .day],
                                                                                 from: oldItem.date,
                                                                                 to: newItem.date)
                                guard let newDate = Calendar.current.date(byAdding: difference, to: item.date) else {
                                    return nil
                                }
                                return ListItem(date: newDate,
                                                content: newItem.content,
                                                group: newItem.group,
                                                income: newItem.income,
                                                expenditure: newItem.expenditure,
                                                original: item.original)
                            }
                            let newItems = ListItems(key: repeatId.description,
                                                     value: newItemList)
                            DataStore.saveAll(context,
                                              items: newItems,
                                              repeatId: repeatId,
                                              completion: completion)
        }
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
