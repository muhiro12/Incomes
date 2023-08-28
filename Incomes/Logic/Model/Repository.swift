//
//  Repository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/08/15.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation

protocol Repository<Entity> {
    associatedtype Entity
    func fetch(predicate: Predicate<Entity>?) throws -> Entity?
    func fetchList(predicate: Predicate<Entity>?) throws -> [Entity]
    func add(_ entity: Entity) throws
    func addList(_ list: [Entity]) throws
    func update(_ entity: Entity) throws
    func updateList(_ list: [Entity]) throws
    func delete(_ entity: Entity) throws
    func deleteList(_ list: [Entity]) throws
}

extension Repository {
    func fetch() throws -> Entity? {
        try fetch(predicate: nil)
    }

    func fetchList() throws -> [Entity] {
        try fetchList(predicate: nil)
    }
}
