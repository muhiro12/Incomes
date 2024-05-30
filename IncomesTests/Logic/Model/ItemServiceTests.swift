//
//  ItemServiceTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import CoreData
@testable import Incomes
import XCTest

// swiftlint:disable all
class ItemServiceTests: XCTestCase {
    override func setUp() {
        NSTimeZone.default = .current
    }

    override func tearDown() {
        NSTimeZone.default = .current
    }

    // MARK: - Create

    func testCreate() {
        XCTContext.runActivity(named: "Result is as expected") { _ in
            let service = ItemService(context: context)

            try! service.create(date: date("2000-01-01T12:00:00Z"),
                                content: "content",
                                income: 200,
                                outgo: 100,
                                group: "group")
            let result = try! service.items().first!

            XCTAssertEqual(result.date, date("2000-01-01T00:00:00Z"))
            XCTAssertEqual(result.content, "content")
            XCTAssertEqual(result.income, 200)
            XCTAssertEqual(result.outgo, 100)
            XCTAssertEqual(result.group, "group")
            XCTAssertEqual(result.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when repeatCount 3") { _ in
            let service = ItemService(context: context)

            try! service.create(date: date("2000-01-01T12:00:00Z"),
                                content: "content",
                                income: 200,
                                outgo: 100,
                                group: "group",
                                repeatCount: 3)
            let first = try! service.items().first!
            let last = try! service.items().last!

            XCTAssertEqual(first.date, date("2000-03-01T00:00:00Z"))
            XCTAssertEqual(first.content, "content")
            XCTAssertEqual(first.income, 200)
            XCTAssertEqual(first.outgo, 100)
            XCTAssertEqual(first.group, "group")
            XCTAssertEqual(first.balance, 300)

            XCTAssertEqual(last.date, date("2000-01-01T00:00:00Z"))
            XCTAssertEqual(last.content, "content")
            XCTAssertEqual(last.income, 200)
            XCTAssertEqual(last.outgo, 100)
            XCTAssertEqual(last.group, "group")
            XCTAssertEqual(last.balance, 100)

            XCTAssertEqual(first.repeatID, last.repeatID)
        }
    }

    // MARK: - Update

    func testUpdate() {
        XCTContext.runActivity(named: "Result is as expected") { _ in
            let service = ItemService(context: context)
            try! service.create(date: date("2000-01-01T12:00:00Z"),
                                content: "content",
                                income: 200,
                                outgo: 100,
                                group: "group")

            try! service.update(item: try! service.items().first!,
                                date: date("2001-01-02T12:00:00Z"),
                                content: "content2",
                                income: 100,
                                outgo: 200,
                                group: "group2")
            let result = try! service.items().first!

            XCTAssertEqual(result.date, date("2001-01-02T00:00:00Z"))
            XCTAssertEqual(result.content, "content2")
            XCTAssertEqual(result.income, 100)
            XCTAssertEqual(result.outgo, 200)
            XCTAssertEqual(result.group, "group2")
            XCTAssertEqual(result.balance, -100)
        }

        XCTContext.runActivity(named: "Result is as expected when repeatCount 3") { _ in
            let service = ItemService(context: context)
            try! service.create(date: date("2000-01-01T12:00:00Z"),
                                content: "content",
                                income: 200,
                                outgo: 100,
                                group: "group",
                                repeatCount: 3)

            try! service.update(item: try! service.items()[1],
                                date: date("2000-02-02T12:00:00Z"),
                                content: "content2",
                                income: 100,
                                outgo: 200,
                                group: "group2")

            let first = try! service.items()[0]
            let second = try! service.items()[1]
            let last = try! service.items()[2]

            XCTAssertEqual(first.date, date("2000-03-01T00:00:00Z"))
            XCTAssertEqual(first.content, "content")
            XCTAssertEqual(first.income, 200)
            XCTAssertEqual(first.outgo, 100)
            XCTAssertEqual(first.group, "group")
            XCTAssertEqual(first.balance, 100)

            XCTAssertEqual(second.date, date("2000-02-02T00:00:00Z"))
            XCTAssertEqual(second.content, "content2")
            XCTAssertEqual(second.income, 100)
            XCTAssertEqual(second.outgo, 200)
            XCTAssertEqual(second.group, "group2")
            XCTAssertEqual(second.balance, 0)

            XCTAssertEqual(last.date, date("2000-01-01T00:00:00Z"))
            XCTAssertEqual(last.content, "content")
            XCTAssertEqual(last.income, 200)
            XCTAssertEqual(last.outgo, 100)
            XCTAssertEqual(last.group, "group")
            XCTAssertEqual(last.balance, 100)

            XCTAssertEqual(first.repeatID, last.repeatID)
            XCTAssertNotEqual(first.repeatID, second.repeatID)
        }
    }

    func testUpdateForFutureItems() {
        XCTContext.runActivity(named: "Result is as expected") { _ in
            let service = ItemService(context: context)
            try! service.create(date: date("2000-01-01T12:00:00Z"),
                                content: "content",
                                income: 200,
                                outgo: 100,
                                group: "group")

            try! service.updateForFutureItems(item: try! service.items().first!,
                                              date: date("2001-01-02T12:00:00Z"),
                                              content: "content2",
                                              income: 100,
                                              outgo: 200,
                                              group: "group2")
            let result = try! service.items().first!

            XCTAssertEqual(result.date, date("2001-01-02T00:00:00Z"))
            XCTAssertEqual(result.content, "content2")
            XCTAssertEqual(result.income, 100)
            XCTAssertEqual(result.outgo, 200)
            XCTAssertEqual(result.group, "group2")
            XCTAssertEqual(result.balance, -100)
        }

        XCTContext.runActivity(named: "Result is as expected when repeatCount 3") { _ in
            let service = ItemService(context: context)
            try! service.create(date: date("2000-01-01T12:00:00Z"),
                                content: "content",
                                income: 200,
                                outgo: 100,
                                group: "group",
                                repeatCount: 3)

            try! service.updateForFutureItems(item: try! service.items()[1],
                                              date: date("2000-02-02T12:00:00Z"),
                                              content: "content2",
                                              income: 100,
                                              outgo: 200,
                                              group: "group2")

            let first = try! service.items()[0]
            let second = try! service.items()[1]
            let last = try! service.items()[2]

            XCTAssertEqual(first.date, date("2000-03-02T00:00:00Z"))
            XCTAssertEqual(first.content, "content2")
            XCTAssertEqual(first.income, 100)
            XCTAssertEqual(first.outgo, 200)
            XCTAssertEqual(first.group, "group2")
            XCTAssertEqual(first.balance, -100)

            XCTAssertEqual(second.date, date("2000-02-02T00:00:00Z"))
            XCTAssertEqual(second.content, "content2")
            XCTAssertEqual(second.income, 100)
            XCTAssertEqual(second.outgo, 200)
            XCTAssertEqual(second.group, "group2")
            XCTAssertEqual(second.balance, 0)

            XCTAssertEqual(last.date, date("2000-01-01T00:00:00Z"))
            XCTAssertEqual(last.content, "content")
            XCTAssertEqual(last.income, 200)
            XCTAssertEqual(last.outgo, 100)
            XCTAssertEqual(last.group, "group")
            XCTAssertEqual(last.balance, 100)

            XCTAssertEqual(first.repeatID, second.repeatID)
            XCTAssertNotEqual(first.repeatID, last.repeatID)
        }
    }

    func testUpdateForAllItems() {
        XCTContext.runActivity(named: "Result is as expected") { _ in
            let service = ItemService(context: context)
            try! service.create(date: date("2000-01-01T12:00:00Z"),
                                content: "content",
                                income: 200,
                                outgo: 100,
                                group: "group")

            try! service.updateForAllItems(item: try! service.items().first!,
                                           date: date("2001-01-02T12:00:00Z"),
                                           content: "content2",
                                           income: 100,
                                           outgo: 200,
                                           group: "group2")
            let result = try! service.items().first!

            XCTAssertEqual(result.date, date("2001-01-02T00:00:00Z"))
            XCTAssertEqual(result.content, "content2")
            XCTAssertEqual(result.income, 100)
            XCTAssertEqual(result.outgo, 200)
            XCTAssertEqual(result.group, "group2")
            XCTAssertEqual(result.balance, -100)
        }

        XCTContext.runActivity(named: "Result is as expected when repeatCount 3") { _ in
            let service = ItemService(context: context)
            try! service.create(date: date("2000-01-01T12:00:00Z"),
                                content: "content",
                                income: 200,
                                outgo: 100,
                                group: "group",
                                repeatCount: 3)

            try! service.updateForAllItems(item: try! service.items()[1],
                                           date: date("2000-02-02T12:00:00Z"),
                                           content: "content2",
                                           income: 100,
                                           outgo: 200,
                                           group: "group2")

            let first = try! service.items()[0]
            let second = try! service.items()[1]
            let last = try! service.items()[2]

            XCTAssertEqual(first.date, date("2000-03-02T00:00:00Z"))
            XCTAssertEqual(first.content, "content2")
            XCTAssertEqual(first.income, 100)
            XCTAssertEqual(first.outgo, 200)
            XCTAssertEqual(first.group, "group2")
            XCTAssertEqual(first.balance, -300)

            XCTAssertEqual(second.date, date("2000-02-02T00:00:00Z"))
            XCTAssertEqual(second.content, "content2")
            XCTAssertEqual(second.income, 100)
            XCTAssertEqual(second.outgo, 200)
            XCTAssertEqual(second.group, "group2")
            XCTAssertEqual(second.balance, -200)

            XCTAssertEqual(last.date, date("2000-01-02T00:00:00Z"))
            XCTAssertEqual(last.content, "content2")
            XCTAssertEqual(last.income, 100)
            XCTAssertEqual(last.outgo, 200)
            XCTAssertEqual(last.group, "group2")
            XCTAssertEqual(last.balance, -100)

            XCTAssertEqual(first.repeatID, second.repeatID)
            XCTAssertEqual(first.repeatID, last.repeatID)
        }
    }

    // MARK: - Delete

    func testDelete() {
        XCTContext.runActivity(named: "") { _ in
            let context = context
            let service = ItemService(context: context)

            let itemA = try! Item.create(context: context,
                                         date: Date(),
                                         content: "",
                                         income: 0,
                                         outgo: 0,
                                         group: "",
                                         repeatID: UUID())
            context.insert(itemA)
            let itemB = try! Item.create(context: context,
                                         date: Date(),
                                         content: "",
                                         income: 0,
                                         outgo: 0,
                                         group: "",
                                         repeatID: UUID())
            context.insert(itemB)
            try! context.save()

            try! service.delete(items: [itemA])

            let result = try! service.items()

            XCTAssertEqual(result, [itemB])
        }
    }

    func testDeleteAll() {
        XCTContext.runActivity(named: "") { _ in
            let context = context
            let service = ItemService(context: context)

            let itemA = try! Item.create(context: context,
                                         date: Date(),
                                         content: "",
                                         income: 0,
                                         outgo: 0,
                                         group: "",
                                         repeatID: UUID())
            context.insert(itemA)
            let itemB = try! Item.create(context: context,
                                         date: Date(),
                                         content: "",
                                         income: 0,
                                         outgo: 0,
                                         group: "",
                                         repeatID: UUID())
            context.insert(itemB)
            try! context.save()

            try! service.deleteAll()

            let result = try! service.items()

            XCTAssertEqual(result, [])
        }
    }
}
// swiftlint:enable all
