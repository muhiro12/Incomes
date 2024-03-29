//
//  BalanceCalculatorTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

@testable import Incomes
import XCTest

// swiftlint:disable all
class BalanceCalculatorTests: XCTestCase {
    func testCalculate() {
        XCTContext.runActivity(named: "Result is as expected when inserting") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
            }
            try! calculator.calculateAll()

            let item = Item()
            item.set(date: date("2000-01-31T12:00:00Z"),
                     content: "content",
                     income: 200,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            context.insert(item)
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when inserting first") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
            }
            try! calculator.calculateAll()

            let item = Item()
            item.set(date: date("2001-01-01T00:00:00Z"),
                     content: "content",
                     income: 200,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            context.insert(item)
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when inserting last") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
            }
            try! calculator.calculateAll()

            let item = Item()
            item.set(date: date("2000-01-01T00:00:00Z"),
                     content: "content",
                     income: 200,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            context.insert(item)
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when updating") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! calculator.calculateAll()

            let item = items[1]
            item.set(date: date("2000-02-01T12:00:00Z"),
                     content: "content",
                     income: 300,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when updating first") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! calculator.calculateAll()

            let item = items[0]
            item.set(date: date("2000-01-01T12:00:00Z"),
                     content: "content",
                     income: 300,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 200)
        }

        XCTContext.runActivity(named: "Result is as expected when updating last") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! calculator.calculateAll()

            let item = items[4]
            item.set(date: date("2000-05-01T12:00:00Z"),
                     content: "content",
                     income: 300,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when changing order") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! calculator.calculateAll()

            let item = items[4]
            item.set(date: date("1999-12-31T00:00:00Z"),
                     content: "content",
                     income: 300,
                     outgo: 100,
                     group: "group",
                     repeatID: UUID())
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 200)
        }

        XCTContext.runActivity(named: "Result is as expected when deleting") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! calculator.calculateAll()

            let item = items[1]
            context.delete(item)
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 400)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when deleting first") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! calculator.calculateAll()

            let item = items[0]
            context.delete(item)
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 400)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when deleting last") { _ in
            let context = context
            let calculator = ItemBalanceCalculator(context: context)

            var items: [Item] = []

            for i in 1...5 {
                let item = Item()
                item.set(date: date("2000-0\(i)-01T12:00:00Z"),
                         content: "content",
                         income: 200,
                         outgo: 100,
                         group: "group",
                         repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! calculator.calculateAll()

            let item = items[4]
            context.delete(item)
            try! calculator.calculate(after: item.date)

            let repository = ItemRepository(context: context)
            let first = try! repository.fetchList().first!
            let last = try! repository.fetchList().last!

            XCTAssertEqual(first.balance, 400)
            XCTAssertEqual(last.balance, 100)
        }
    }
}
// swiftlint:enable all
