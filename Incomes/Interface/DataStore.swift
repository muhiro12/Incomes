//
//  DataStore.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/29.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct DataStore {
    static func fetch(_ context: NSManagedObjectContext,
                      format: String,
                      keys: [Any]?,
                      completion: ((ListItems) -> Void)? = nil) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: .item)
        request.predicate = NSPredicate(format: format, argumentArray: keys)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.date, ascending: true)]

        do {
            let result = try context.fetch(request) as? [Item] ?? []
            completion?(ListItems(from: result, for: keys.string))
        } catch {
            print(error)
        }
    }

    static func save(_ context: NSManagedObjectContext,
                     item: ListItem,
                     completion: (() -> Void)? = nil) {
        convert(context, item: item)
        do {
            try context.save()
            completion?()
        } catch {
            print(error)
        }
    }

    static func saveAll(_ context: NSManagedObjectContext,
                        items: ListItems,
                        repeatId: UUID? = nil,
                        completion: (() -> Void)? = nil) {
        items.value.forEach { item in
            convert(context,
                    item: item,
                    repeatId: repeatId)
        }
        do {
            try context.save()
            completion?()
        } catch {
            print(error)
        }
    }

    static func delete(_ context: NSManagedObjectContext,
                       item: ListItem,
                       completion: (() -> Void)? = nil) {
        guard let original = item.original else {
            return
        }
        context.delete(original)
        completion?()
    }

    static private func convert(_ context: NSManagedObjectContext,
                                item: ListItem,
                                repeatId: UUID? = nil) {
        let original = item.original ?? Item(context: context)
        original.date = item.date
        original.content = item.content
        original.group = item.group
        original.income = item.income.asNSDecimalNumber
        original.expenditure = item.expenditure.asNSDecimalNumber
        original.repeatId = repeatId
    }
}
