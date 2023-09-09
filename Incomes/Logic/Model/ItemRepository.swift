//
//  ItemRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct ItemRepository: Repository {
    typealias Entity = Item

    private let context: ModelContext
    private let calculator: BalanceCalculator

    init(context: ModelContext) {
        self.context = context
        self.calculator = BalanceCalculator(context: context)
    }

    func fetch(predicate: Predicate<Item>?) throws -> Item? {
        var descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: Item.sortDescriptors()
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
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

private extension ItemRepository {
    func save() throws {
        try calculator.calculate()
    }
}
