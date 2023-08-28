//
//  ItemRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

class ItemRepository: Repository {
    typealias Entity = Item

    private let context: ModelContext

    private lazy var calculator = BalanceCalculator(context: context, repository: self)

    init(context: ModelContext) {
        self.context = context
    }

    func fetch(predicate: Predicate<Item>?) throws -> Item? {
        try fetchList(predicate: predicate).first
    }

    func fetchList(predicate: Predicate<Item>?) throws -> [Item] {
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: Item.sortDescriptors()
        )
        return try context.fetch(descriptor)
    }

    func add(_ entity: Item) throws {
        context.insert(entity)
        try save()
    }

    func addList(_ list: [Item]) throws {
        list.forEach(context.insert)
        try save()
    }

    func update(_ entity: Item) throws {
        try save()
    }

    func updateList(_ list: [Item]) throws {
        try save()
    }

    func delete(_ entity: Item) throws {
        context.delete(entity)
        try save()
    }

    func deleteList(_ list: [Item]) throws {
        list.forEach(context.delete)
        try save()
    }
}

extension ItemRepository {
    private func save() throws {
        try calculator.calculate()
        try context.save()
    }
}
