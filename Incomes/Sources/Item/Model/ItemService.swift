//
//  ItemService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

@Observable
final class ItemService {
    private let context: ModelContext
    private let calculator: BalanceCalculator

    init(context: ModelContext) {
        self.context = context
        self.calculator = .init(context: context)
    }

    // MARK: - Fetch

    func model(of entity: ItemEntity) throws -> Item {
        let descriptor = FetchDescriptor.items(.idIs(.init(base64Encoded: entity.id)))
        guard let model = try context.fetchFirst(descriptor) else {
            throw ItemError.itemNotFound
        }
        return model
    }

    // MARK: - Calculate balance

    func recalculate(after date: Date) throws {
        try calculator.calculate(after: date)
    }
}

