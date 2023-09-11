//
//  SwiftDataRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/11.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

protocol SwiftDataRepository<Entity>: Repository where Entity: PersistentModel {
    var controller: SwiftDataController { get }
    var sortDescriptors: [SortDescriptor<Entity>] { get }

    init(context: ModelContext)

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
    func fetch(predicate: Predicate<Entity>?) throws -> Entity? {
        try controller.fetch(predicate: predicate,
                             sortBy: sortDescriptors)
    }

    func fetchList(predicate: Predicate<Entity>?) throws -> [Entity] {
        try controller.fetchList(predicate: predicate,
                                 sortBy: sortDescriptors)
    }

    func add(_ entity: Entity) throws {
        try controller.add(entity)
    }

    func addList(_ list: [Entity]) throws {
        try controller.addList(list)
    }

    func update(_ entity: Entity) throws {
        try controller.update(entity)
    }

    func updateList(_ list: [Entity]) throws {
        try controller.updateList(list)
    }

    func delete(_ entity: Entity) throws {
        try controller.delete(entity)
    }

    func deleteList(_ list: [Entity]) throws {
        try controller.deleteList(list)
    }
}
