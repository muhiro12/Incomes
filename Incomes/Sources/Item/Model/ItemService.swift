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

    func item(_ descriptor: FetchDescriptor<Item> = .items(.all)) throws -> Item? {
        try context.fetchFirst(descriptor)
    }

    func items(_ descriptor: FetchDescriptor<Item> = .items(.all)) throws -> [Item] {
        try context.fetch(descriptor)
    }

    func model(of entity: ItemEntity) throws -> Item {
        guard let model = try item(.items(.idIs(.init(base64Encoded: entity.id)))) else {
            throw DebugError.default
        }
        return model
    }

    func itemsCount(_ descriptor: FetchDescriptor<Item> = .items(.all)) throws -> Int {
        try context.fetchCount(descriptor)
    }

    // MARK: - Calculate balance

    func recalculate(after date: Date) throws {
        try calculator.calculate(after: date)
    }
}

