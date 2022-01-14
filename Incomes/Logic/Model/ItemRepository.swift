//
//  ItemRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct ItemRepository {
    private let context: NSManagedObjectContext
    private let calculator: BalanceCalculator

    init(context: NSManagedObjectContext) {
        self.context = context
        self.calculator = .init(context: context)
    }

    // MARK: - Fetch

    func items(predicate: NSPredicate? = nil) throws -> [Item] {
        let request = Item.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = NSSortDescriptor.standards
        return try context.fetch(request)
    }

    // MARK: - Insert

    func insert(items: [Item]) throws {
        items.forEach {
            context.insert($0)
        }
        try calculator.calculate()
    }

    // MARK: - Update

    func update() throws {
        try calculator.calculate()
    }

    // MARK: - Delete

    func delete(items: [Item]) throws {
        items.forEach {
            context.delete($0)
        }
        try calculator.calculate()
    }

    func deleteAll() {
        context.refreshAllObjects()
    }

    // MARK: - Calculate

    func recalculate() throws {
        try calculator.recalculate()
    }
}
