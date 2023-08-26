//
//  ItemRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import CoreData
import Foundation

class ItemRepository: Repository {
    typealias Entity = Item

    private let context: NSManagedObjectContext

    private lazy var calculator = BalanceCalculator(context: context, repository: self)

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetch(predicate: NSPredicate?) throws -> Item {
        guard let item = try fetchList(predicate: predicate).first else {
            assertionFailure()
            return Item()
        }
        return item
    }

    func fetchList(predicate: NSPredicate?) throws -> [Item] {
        let request = Item.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = NSSortDescriptor.standards
        return try context.fetch(request)
    }

    func add(_ entity: Item) throws {
        try save()
    }

    func addList(_ list: [Item]) throws {
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
        list.forEach {
            context.delete($0)
        }
        try save()
    }
}

extension ItemRepository {
    private func save() throws {
        try calculator.calculate()
        try context.save()
    }
}
