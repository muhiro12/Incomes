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
    private let repository: ItemRepository
    private let calculator: ItemBalanceCalculator

    init(context: ModelContext) {
        self.repository = .init(context: context)
        self.calculator = .init(context: context)
    }

    func delete(items: [Item]) throws {
        try repository.deleteList(items)
        try calculator.calculate(for: items)
    }

    func deleteAll() throws {
        try delete(items: repository.fetchList())
    }
}
