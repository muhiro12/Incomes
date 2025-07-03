//
//  BalanceCalculatorTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

@testable import Incomes
import XCTest

final class BalanceCalculatorTests: XCTestCase {
    func testCalculate() {
        XCTContext.runActivity(named: "Result is as expected when inserting") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = try! Item.create(container: container,
                                        date: shiftedDate("2000-01-31T12:00:00Z"),
                                        content: "content",
                                        income: 200,
                                        outgo: 100,
                                        category: "category",
                                        repeatID: UUID())
            container.mainContext.insert(item)
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when inserting first") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = try! Item.create(container: container,
                                        date: shiftedDate("2001-01-01T00:00:00Z"),
                                        content: "content",
                                        income: 200,
                                        outgo: 100,
                                        category: "category",
                                        repeatID: UUID())
            container.mainContext.insert(item)
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when inserting last") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = try! Item.create(container: container,
                                        date: shiftedDate("2000-01-01T00:00:00Z"),
                                        content: "content",
                                        income: 200,
                                        outgo: 100,
                                        category: "category",
                                        repeatID: UUID())
            container.mainContext.insert(item)
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when updating") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            var items: [Item] = []

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
                items.append(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = items[1]
            try! item.modify(date: shiftedDate("2000-02-01T12:00:00Z"),
                             content: "content",
                             income: 300,
                             outgo: 100,
                             category: "category",
                             repeatID: UUID())
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when updating first") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            var items: [Item] = []

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
                items.append(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = items[0]
            try! item.modify(date: shiftedDate("2000-01-01T12:00:00Z"),
                             content: "content",
                             income: 300,
                             outgo: 100,
                             category: "category",
                             repeatID: UUID())
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 200)
        }

        XCTContext.runActivity(named: "Result is as expected when updating last") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            var items: [Item] = []

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
                items.append(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = items[4]
            try! item.modify(date: shiftedDate("2000-05-01T12:00:00Z"),
                             content: "content",
                             income: 300,
                             outgo: 100,
                             category: "category",
                             repeatID: UUID())
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when changing order") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            var items: [Item] = []

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
                items.append(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = items[4]
            try! item.modify(date: shiftedDate("1999-12-31T00:00:00Z"),
                             content: "content",
                             income: 300,
                             outgo: 100,
                             category: "category",
                             repeatID: UUID())
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 600)
            XCTAssertEqual(last.balance, 200)
        }

        XCTContext.runActivity(named: "Result is as expected when deleting") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            var items: [Item] = []

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
                items.append(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = items[1]
            container.mainContext.delete(item)
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 400)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when deleting first") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            var items: [Item] = []

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
                items.append(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = items[0]
            container.mainContext.delete(item)
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 400)
            XCTAssertEqual(last.balance, 100)
        }

        XCTContext.runActivity(named: "Result is as expected when deleting last") { _ in
            let container = testContainer
            let calculator = BalanceCalculator()

            var items: [Item] = []

            for i in 1...5 {
                let item = try! Item.create(container: container,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            repeatID: UUID())
                container.mainContext.insert(item)
                items.append(item)
            }
            try! calculator.calculate(in: container.mainContext, after: .distantPast)

            let item = items[4]
            container.mainContext.delete(item)
            try! calculator.calculate(in: container.mainContext, after: item.localDate)

            let first = fetchItems(container).first!
            let last = fetchItems(container).last!

            XCTAssertEqual(first.balance, 400)
            XCTAssertEqual(last.balance, 100)
        }
    }
}
