//
//  ItemRepositoryTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes
import CoreData

// swiftlint:disable all
class ItemRepositoryTests: XCTestCase {
    var context: NSManagedObjectContext {
        PersistenceController(inMemory: true).container.viewContext
    }

    let date: (String) -> Date = { string in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .init(secondsFromGMT: 0)
        return formatter.date(from: string)!
    }

    // MARK: - Create

    func testCreate() {
        XCTContext.runActivity(named: "Result is as expected") { _ in
            let repository = ItemRepository(context: context)

            try! repository.create(date: date("2000/01/01 12:00:00"),
                                   content: "content",
                                   income: 200,
                                   outgo: 100,
                                   group: "group")
            let result = try! repository.items().first!

            XCTAssertEqual(result.date, date("2000/01/01 12:00:00"))
            XCTAssertEqual(result.content, "content")
            XCTAssertEqual(result.income, 200)
            XCTAssertEqual(result.outgo, 100)
            XCTAssertEqual(result.group, "group")
            XCTAssertEqual(result.year, date("2000/01/01 00:00:00"))
            XCTAssertEqual(result.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when repeatCount 2") { _ in
            let repository = ItemRepository(context: context)

            try! repository.create(date: date("2000/01/01 12:00:00"),
                                   content: "content",
                                   income: 200,
                                   outgo: 100,
                                   group: "group",
                                   repeatCount: 2)
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.date, date("2000/02/01 12:00:00"))
            XCTAssertEqual(first.content, "content")
            XCTAssertEqual(first.income, 200)
            XCTAssertEqual(first.outgo, 100)
            XCTAssertEqual(first.group, "group")
            XCTAssertEqual(first.year, date("2000/01/01 00:00:00"))
            XCTAssertEqual(first.balance, 200)

            XCTAssertEqual(last.date, date("2000/01/01 12:00:00"))
            XCTAssertEqual(last.content, "content")
            XCTAssertEqual(last.income, 200)
            XCTAssertEqual(last.outgo, 100)
            XCTAssertEqual(last.group, "group")
            XCTAssertEqual(last.year, date("2000/01/01 00:00:00"))
            XCTAssertEqual(last.balance, 100)

            XCTAssertEqual(first.repeatID, last.repeatID)
        }
    }

    // MARK: - Calculate balance

    func testCalculate() {
        XCTContext.runActivity(named: "Result is as expected") { _ in
            let repository = ItemRepository(context: context)

            for _ in 1...5 {
                let item = Item(context: repository.context)
                item.set(date: date("2000/01/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            }
            try! repository.calculate()
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 500)
            XCTAssertEqual(last.balance, 100)
        }
    }

    func testCalculateForFutureItems() {
        XCTContext.runActivity(named: "Result is as expected when inserting") { _ in
            let repository = ItemRepository(context: context)

            for i in 1...5 {
                let item = Item(context: repository.context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            }
            try! repository.calculate()

            let item = Item(context: repository.context)
            item.set(date: date("2000/01/31 12:00:00"),
                     content: "content",
                     income: 200,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())

            try! repository.calculateForFutureItems()
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when inserting first") { _ in
            let repository = ItemRepository(context: context)

            for i in 1...5 {
                let item = Item(context: repository.context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            }
            try! repository.calculate()

            let item = Item(context: repository.context)
            item.set(date: date("2001/01/01 00:00:00"),
                     content: "content",
                     income: 200,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())

            try! repository.calculateForFutureItems()
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when inserting last") { _ in
            let repository = ItemRepository(context: context)

            for i in 1...5 {
                let item = Item(context: repository.context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            }
            try! repository.calculate()

            let item = Item(context: repository.context)
            item.set(date: date("2000/01/01 00:00:00"),
                     content: "content",
                     income: 200,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())

            try! repository.calculateForFutureItems()
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when updating") { _ in
            let repository = ItemRepository(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item(context: repository.context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                items.append(item)
            }
            try! repository.calculate()

            items[1].set(date: date("2000/02/01 12:00:00"),
                         content: "content",
                         income: 300,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())

            try! repository.calculateForFutureItems()
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when updating first") { _ in
            let repository = ItemRepository(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item(context: repository.context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                items.append(item)
            }
            try! repository.calculate()

            items[0].set(date: date("2000/01/01 12:00:00"),
                         content: "content",
                         income: 300,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())

            try! repository.calculateForFutureItems()
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 200)
        }

        XCTContext.runActivity(named: "Result is as expected when updating last") { _ in
            let repository = ItemRepository(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item(context: repository.context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                items.append(item)
            }
            try! repository.calculate()

            items[4].set(date: date("2000/05/01 12:00:00"),
                         content: "content",
                         income: 300,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())

            try! repository.calculateForFutureItems()
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when changing order") { _ in
            let repository = ItemRepository(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item(context: repository.context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                items.append(item)
            }
            try! repository.calculate()

            items[4].set(date: date("2000/01/01 00:00:00"),
                         content: "content",
                         income: 300,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())

            try! repository.calculateForFutureItems()
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 200)
        }
    }
}
