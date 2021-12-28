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
    static func listItems(_ context: NSManagedObjectContext,
                          format: String,
                          keys: [Any]?) async throws -> ListItems {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: .item)
        request.predicate = NSPredicate(format: format, argumentArray: keys)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.date, ascending: true)]
        let result = try context.fetch(request) as? [Item] ?? []
        return ListItems(from: result, for: keys.unwrappedString)
    }

    static func save(_ context: NSManagedObjectContext, item: Item) throws {
        try context.save()
    }

    static func saveAll(_ context: NSManagedObjectContext,
                        items: ListItems,
                        repeatId: UUID? = nil) throws {
        try context.save()
    }

    static func delete(_ context: NSManagedObjectContext, item: Item) {
        context.delete(item)
    }
}
