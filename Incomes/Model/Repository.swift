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
    static func save(_ context: NSManagedObjectContext,
                     original: Item,
                     item listItem: ListItem,
                     completion: (() -> Void)? = nil) {

        original.date = listItem.date
        original.content = listItem.content
        original.income = listItem.income.asNSDecimalNumber
        original.expenditure = listItem.expenditure.asNSDecimalNumber
        original.group = listItem.group
        original.repeatId = nil

        DataStore.save(context, completion: completion)
    }

    static func create(_ context: NSManagedObjectContext,
                       item listItem: ListItem,
                       repeatCount: Int,
                       completion: (() -> Void)? = nil) {

        let repeatId = UUID()

        for index in 0..<repeatCount {
            let item = Item(context: context)
            item.date = Calendar.current.date(byAdding: .month,
                                              value: index,
                                              to: listItem.date)
            item.content = listItem.content
            item.income = listItem.income.asNSDecimalNumber
            item.expenditure = listItem.expenditure.asNSDecimalNumber
            item.group = listItem.group
            item.repeatId = repeatId
        }

        DataStore.save(context, completion: completion)
    }

    static func delete(_ context: NSManagedObjectContext,
                       item: Item,
                       completion: (() -> Void)? = nil) {
        DataStore.delete(context, item: item, completion: completion)
    }
}
