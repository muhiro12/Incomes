//
//  BalanceCalculatorTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes
import CoreData

// swiftlint:disable all
class BalanceCalculatorTests: XCTestCase {
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

    func testCalculate() {
        XCTContext.runActivity(named: "Result is as expected when inserting") { _ in
            let context = context
            let calculator = BalanceCalculator(context: context)

            for i in 1...5 {
                let item = Item(context: context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            }
            try! calculator.calculate()

            let item = Item(context: context)
            item.set(date: date("2000/01/31 12:00:00"),
                     content: "content",
                     income: 200,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            try! calculator.calculate()

            let repository = ItemRepository(context: context)
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when inserting first") { _ in
            let context = context
            let calculator = BalanceCalculator(context: context)

            for i in 1...5 {
                let item = Item(context: context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            }
            try! calculator.calculate()

            let item = Item(context: context)
            item.set(date: date("2001/01/01 00:00:00"),
                     content: "content",
                     income: 200,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            try! calculator.calculate()

            let repository = ItemRepository(context: context)
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when inserting last") { _ in
            let context = context
            let calculator = BalanceCalculator(context: context)

            for i in 1...5 {
                let item = Item(context: context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            }
            try! calculator.calculate()

            let item = Item(context: context)
            item.set(date: date("2000/01/01 00:00:00"),
                     content: "content",
                     income: 200,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            try! calculator.calculate()

            let repository = ItemRepository(context: context)
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when updating") { _ in
            let context = context
            let calculator = BalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item(context: context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                items.append(item)
            }
            try! calculator.calculate()

            items[1].set(date: date("2000/02/01 12:00:00"),
                         content: "content",
                         income: 300,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            try! calculator.calculate()

            let repository = ItemRepository(context: context)
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when updating first") { _ in
            let context = context
            let calculator = BalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item(context: context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                items.append(item)
            }
            try! calculator.calculate()

            items[0].set(date: date("2000/01/01 12:00:00"),
                         content: "content",
                         income: 300,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            try! calculator.calculate()

            let repository = ItemRepository(context: context)
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 200)
        }

        XCTContext.runActivity(named: "Result is as expected when updating last") { _ in
            let context = context
            let calculator = BalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item(context: context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                items.append(item)
            }
            try! calculator.calculate()

            items[4].set(date: date("2000/05/01 12:00:00"),
                         content: "content",
                         income: 300,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            try! calculator.calculate()

            let repository = ItemRepository(context: context)
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when changing order") { _ in
            let context = context
            let calculator = BalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item(context: context)
                item.set(date: date("2000/0\(i)/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                items.append(item)
            }
            try! calculator.calculate()

            items[4].set(date: date("2000/01/01 00:00:00"),
                         content: "content",
                         income: 300,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            try! calculator.calculate()

            let repository = ItemRepository(context: context)
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 200)
        }
    }

    func testRecalculate() {
        XCTContext.runActivity(named: "Result is as expected") { _ in
            let context = context
            let calculator = BalanceCalculator(context: context)

            for _ in 1...5 {
                let item = Item(context: context)
                item.set(date: date("2000/01/01 12:00:00"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
            }
            try! calculator.recalculate()

            let repository = ItemRepository(context: context)
            let first = try! repository.items().first!
            let last = try! repository.items().last!

            XCTAssertEqual(first.balance, 500)
            XCTAssertEqual(last.balance, 100)
        }
    }
}
