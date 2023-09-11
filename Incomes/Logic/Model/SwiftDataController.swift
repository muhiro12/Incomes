//
//  SwiftDataController.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/11.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct SwiftDataController {
    let context: ModelContext

    func fetch<T: PersistentModel>(predicate: Predicate<T>? = nil, sortBy: [SortDescriptor<T>] = []) throws -> T? {
        var descriptor = FetchDescriptor<T>(
            predicate: predicate,
            sortBy: sortBy
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func fetchList<T: PersistentModel>(predicate: Predicate<T>? = nil, sortBy: [SortDescriptor<T>] = []) throws -> [T] {
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: sortBy
        )
        return try context.fetch(descriptor)
    }

    func add<T: PersistentModel>(_ entity: T) throws {
        context.insert(entity)
        try context.save()
    }

    func addList<T: PersistentModel>(_ list: [T]) throws {
        list.forEach(context.insert)
        try context.save()
    }

    func update<T: PersistentModel>(_ entity: T) throws {
        try context.save()
    }

    func updateList<T: PersistentModel>(_ list: [T]) throws {
        try context.save()
    }

    func delete<T: PersistentModel>(_ entity: T) throws {
        context.delete(entity)
        try context.save()
    }

    func deleteList<T: PersistentModel>(_ list: [T]) throws {
        list.forEach(context.delete)
        try context.save()
    }
}
