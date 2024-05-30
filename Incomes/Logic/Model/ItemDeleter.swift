//
//  ItemDeleter.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/10/30.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct ItemDeleter {
    private let context: ModelContext
    private let calculator: ItemBalanceCalculator

    init(context: ModelContext) {
        self.context = context
        self.calculator = .init(context: context)
    }

    func delete(items: [Item]) throws {
        items.forEach(context.delete)
        try context.save()
        try calculator.calculate(for: items)
    }

    func deleteAll() throws {
        try delete(items: try context.fetch(.init()))
    }
}
