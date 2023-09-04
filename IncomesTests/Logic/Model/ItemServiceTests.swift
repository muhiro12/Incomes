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

            let itemA = Item(date: Date(),
                             content: "",
                             income: 0,
                             outgo: 0,
                             group: "",
                             repeatID: UUID())
            context.insert(itemA)
            let itemB = Item(date: Date(),
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

            let itemA = Item(date: Date(),
                             content: "",
                             income: 0,
                             outgo: 0,
                             group: "",
                             repeatID: UUID())
            context.insert(itemA)
            let itemB = Item(date: Date(),
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

    // MARK: - Utilitiy

    func testGroupByMonth() {
        let data = PreviewData.items
        let result = ItemService.groupByMonth(items: data)

        XCTContext.runActivity(named: "Result is sorted in descending by month") { _ in
            XCTAssertTrue(result[0].section > result[1].section)
            XCTAssertTrue(result[1].section > result[2].section)
            XCTAssertTrue(result[2].section > result[3].section)
        }

        XCTContext.runActivity(named: "Items order is not changed") { _ in
            XCTAssertEqual(result.first!.items[0].content, data[0].content)
            XCTAssertEqual(result.first!.items[1].content, data[1].content)
            XCTAssertEqual(result.first!.items[2].content, data[2].content)
        }

        XCTContext.runActivity(named: "First items are Dec.") { _ in
            result.first!.items.forEach {
                XCTAssertEqual(Calendar.utc.component(.month, from: $0.date),
                               12)
            }
        }

        XCTContext.runActivity(named: "Last items are Jan.") { _ in
            result.last!.items.forEach {
                XCTAssertEqual(Calendar.utc.component(.month, from: $0.date),
                               1)
            }
        }
    }

    func testGroupByMonthLondon() {
        NSTimeZone.default = .init(identifier: "Europe/London")!
        testGroupByMonth()
    }

    func testGroupByMonthNewYork() {
        NSTimeZone.default = .init(identifier: "America/New_York")!
        testGroupByMonth()
    }

    func testGroupByMonthTokyo() {
        NSTimeZone.default = .init(identifier: "Asia/Tokyo")!
        testGroupByMonth()
    }

    func testGroupByContent() {
        let data = PreviewData.items
        let result = ItemService.groupByContent(items: data)

        XCTContext.runActivity(named: "Result is sorted in ascending by content") { _ in
            XCTAssertTrue(result[0].section < result[1].section)
            XCTAssertTrue(result[1].section < result[2].section)
            XCTAssertTrue(result[2].section < result[3].section)
        }

        XCTContext.runActivity(named: "Items order is not changed") { _ in
            XCTAssertEqual(Calendar.utc.component(.month, from: result.first!.items[0].date),
                           1)
            XCTAssertEqual(Calendar.utc.component(.month, from: result.first!.items[1].date),
                           2)
            XCTAssertEqual(Calendar.utc.component(.month, from: result.first!.items[2].date),
                           3)
        }
    }
}
// swiftlint:enable all
