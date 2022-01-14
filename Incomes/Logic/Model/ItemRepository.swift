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

    func items(predicate: NSPredicate? = nil) throws -> [Item] {
        let request = Item.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = NSSortDescriptor.standards
        return try context.fetch(request)
    }

    func instantiate(date: Date, // swiftlint:disable:this function_parameter_count
                     content: String,
                     income: NSDecimalNumber,
                     outgo: NSDecimalNumber,
                     group: String,
                     repeatID: UUID) -> Item {
        let item = Item(context: context)
        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: repeatID)
        return item
    }

    func save() throws {
        try calculator.calculate()
    }

    func delete(items: [Item]) throws {
        items.forEach {
            context.delete($0)
        }
        try calculator.calculate()
    }

    func recalculate() throws {
        try calculator.recalculate()
    }
}
