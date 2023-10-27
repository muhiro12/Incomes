//
//  SwiftDataRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/11.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

// periphery:ignore
protocol SwiftDataRepository<Entity> where Entity: PersistentModel {
    associatedtype Entity

    var context: ModelContext { get }
    var sortDescriptors: [SortDescriptor<Entity>] { get }

    func fetch(predicate: Predicate<Entity>?) throws -> Entity?
    func fetchList(predicate: Predicate<Entity>?) throws -> [Entity]
    func add(_ entity: Entity) throws
    func addList(_ list: [Entity]) throws
    func update(_ entity: Entity) throws
    func updateList(_ list: [Entity]) throws
    func delete(_ entity: Entity) throws
    func deleteList(_ list: [Entity]) throws
}

extension SwiftDataRepository {
    func fetch(predicate: Predicate<Entity>? = nil) throws -> Entity? {
        var descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func fetchList(predicate: Predicate<Entity>? = nil) throws -> [Entity] {
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        return try context.fetch(descriptor)
    }

    func add(_ entity: Entity) throws {
        context.insert(entity)
        try context.save()
    }

    func addList(_ list: [Entity]) throws {
        list.forEach(context.insert)
        try context.save()
    }

    func update(_ entity: Entity) throws {
        try context.save()
    }

    func updateList(_ list: [Entity]) throws {
        try context.save()
    }

    func delete(_ entity: Entity) throws {
        context.delete(entity)
        try context.save()
    }

    func deleteList(_ list: [Entity]) throws {
        list.forEach(context.delete)
        try context.save()
    }
}
