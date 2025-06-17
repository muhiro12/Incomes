//
//  ItemServiceXCTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

@testable import Incomes
import SwiftData
import XCTest

final class ItemServiceXCTests: XCTestCase {
    // MARK: - Delete

    func testDelete() {
        XCTContext.runActivity(named: "") { _ in
            let context = testContext

            let itemA = try! Item.create(context: context,
                                         date: .now,
                                         content: "",
                                         income: 0,
                                         outgo: 0,
                                         category: "",
                                         repeatID: UUID())
            context.insert(itemA)
            let itemB = try! Item.create(context: context,
                                         date: .now,
                                         content: "",
                                         income: 0,
                                         outgo: 0,
                                         category: "",
                                         repeatID: UUID())
            context.insert(itemB)

            try! DeleteItemIntent.perform(
                (
                    context: context,
                    item: ItemEntity(itemA)!
                )
            )

            let result = fetchItems(context)

            XCTAssertEqual(result, [itemB])
        }
    }

    func testDeleteAll() {
        XCTContext.runActivity(named: "") { _ in
            let context = testContext

            let itemA = try! Item.create(context: context,
                                         date: .now,
                                         content: "",
                                         income: 0,
                                         outgo: 0,
                                         category: "",
                                         repeatID: UUID())
            context.insert(itemA)
            let itemB = try! Item.create(context: context,
                                         date: .now,
                                         content: "",
                                         income: 0,
                                         outgo: 0,
                                         category: "",
                                         repeatID: UUID())
            context.insert(itemB)

            try! DeleteAllItemsIntent.perform(context)

            let result = fetchItems(context)

            XCTAssertEqual(result, [])
        }
    }
}
