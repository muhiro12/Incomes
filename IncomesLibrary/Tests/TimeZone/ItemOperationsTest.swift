//
//  ItemOperationsTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemOperationsTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @discardableResult
    func createTestItem(
        input: ItemFormInput,
        repeatCount: Int = 1
    ) throws -> Item {
        try createItem(
            context: context,
            input: input,
            repeatCount: repeatCount
        )
    }

    func updateTestItem(
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope = .thisItem
    ) throws {
        try updateItem(
            context: context,
            item: item,
            input: input,
            scope: scope
        )
    }
}
