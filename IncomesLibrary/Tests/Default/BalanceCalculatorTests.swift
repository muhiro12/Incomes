//
//  BalanceCalculatorTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import IncomesLibrary
import Testing

struct BalanceCalculatorTests {
    struct CalculateTests {
        @Test("Result is as expected when inserting")
        func inserting_is_expected() {
            let context = testContext
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = try! Item.create(context: context,
                                        date: shiftedDate("2000-01-31T12:00:00Z"),
                                        content: "content",
                                        income: 200,
                                        outgo: 100,
                                        category: "category",
                                        priority: 0,
                                        repeatID: UUID())
            context.insert(item)
            try! BalanceCalculator.calculate(in: context, after: item.localDate)

            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when inserting first")
        func inserting_first_is_expected() {
            let context = testContext
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = try! Item.create(context: context,
                                        date: shiftedDate("2001-01-01T00:00:00Z"),
                                        content: "content",
                                        income: 200,
                                        outgo: 100,
                                        category: "category",
                                        priority: 0,
                                        repeatID: UUID())
            context.insert(item)
            try! BalanceCalculator.calculate(in: context, after: item.localDate)

            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when inserting last")
        func inserting_last_is_expected() {
            let context = testContext
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = try! Item.create(context: context,
                                        date: shiftedDate("2000-01-01T00:00:00Z"),
                                        content: "content",
                                        income: 200,
                                        outgo: 100,
                                        category: "category",
                                        priority: 0,
                                        repeatID: UUID())
            context.insert(item)
            try! BalanceCalculator.calculate(in: context, after: item.localDate)

            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when priorities share the same date")
        func priority_order_is_expected() {
            let context = testContext
            let baseDate = shiftedDate("2000-01-01T12:00:00Z")
            let lowPriorityItem = try! Item.create(context: context,
                                                   date: baseDate,
                                                   content: "Low",
                                                   income: 0,
                                                   outgo: 50,
                                                   category: "category",
                                                   priority: 0,
                                                   repeatID: UUID())
            let highPriorityItem = try! Item.create(context: context,
                                                    date: baseDate,
                                                    content: "High",
                                                    income: 100,
                                                    outgo: 0,
                                                    category: "category",
                                                    priority: 10,
                                                    repeatID: UUID())
            context.insert(lowPriorityItem)
            context.insert(highPriorityItem)

            try! BalanceCalculator.calculate(in: context, after: .distantPast)

            let items = try! context.fetch(.items(.all, order: .forward))
            #expect(items.count == 2)
            #expect(items[0].priority == 10)
            #expect(items[0].balance == 100)
            #expect(items[1].priority == 0)
            #expect(items[1].balance == 50)
        }

        @Test("List order respects content name when priorities match")
        func list_name_order_is_expected() {
            let context = testContext
            let baseDate = shiftedDate("2000-01-01T12:00:00Z")
            let firstItem = try! Item.create(context: context,
                                             date: baseDate,
                                             content: "Item A",
                                             income: 0,
                                             outgo: 10,
                                             category: "category",
                                             priority: 0,
                                             repeatID: UUID())
            let secondItem = try! Item.create(context: context,
                                              date: baseDate,
                                              content: "Item B",
                                              income: 0,
                                              outgo: 20,
                                              category: "category",
                                              priority: 0,
                                              repeatID: UUID())
            context.insert(firstItem)
            context.insert(secondItem)

            let items = try! context.fetch(.items(.all, order: .reverse))
            #expect(items.count == 2)
            #expect(items[0].content == "Item B")
            #expect(items[1].content == "Item A")
        }

        @Test("List order is as expected when priorities share the same date")
        func list_priority_order_is_expected() {
            let context = testContext
            let baseDate = shiftedDate("2000-01-01T12:00:00Z")
            let lowPriorityItem = try! Item.create(context: context,
                                                   date: baseDate,
                                                   content: "Item A",
                                                   income: 0,
                                                   outgo: 50,
                                                   category: "category",
                                                   priority: 0,
                                                   repeatID: UUID())
            let highPriorityItem = try! Item.create(context: context,
                                                    date: baseDate,
                                                    content: "Item B",
                                                    income: 100,
                                                    outgo: 0,
                                                    category: "category",
                                                    priority: 1,
                                                    repeatID: UUID())
            context.insert(lowPriorityItem)
            context.insert(highPriorityItem)

            let items = try! context.fetch(.items(.all, order: .reverse))
            #expect(items.count == 2)
            #expect(items[0].content == "Item A")
            #expect(items[1].content == "Item B")
        }

        @Test("List order is consistent between priority 0/1 and 1/2")
        func list_priority_order_is_consistent() {
            let context = testContext
            let baseDate = shiftedDate("2000-01-01T12:00:00Z")
            let firstItem = try! Item.create(context: context,
                                             date: baseDate,
                                             content: "Item A",
                                             income: 0,
                                             outgo: 10,
                                             category: "category",
                                             priority: 1,
                                             repeatID: UUID())
            let secondItem = try! Item.create(context: context,
                                              date: baseDate,
                                              content: "Item B",
                                              income: 0,
                                              outgo: 20,
                                              category: "category",
                                              priority: 2,
                                              repeatID: UUID())
            context.insert(firstItem)
            context.insert(secondItem)

            let items = try! context.fetch(.items(.all, order: .reverse))
            #expect(items.count == 2)
            #expect(items[0].content == "Item A")
            #expect(items[1].content == "Item B")
        }

        @Test("Comparable order respects content name when priorities match")
        func comparable_name_order_is_expected() {
            let context = testContext
            let baseDate = shiftedDate("2000-01-01T12:00:00Z")
            let firstItem = try! Item.create(context: context,
                                             date: baseDate,
                                             content: "Item A",
                                             income: 0,
                                             outgo: 10,
                                             category: "category",
                                             priority: 0,
                                             repeatID: UUID())
            let secondItem = try! Item.create(context: context,
                                              date: baseDate,
                                              content: "Item B",
                                              income: 0,
                                              outgo: 20,
                                              category: "category",
                                              priority: 0,
                                              repeatID: UUID())

            let items = [firstItem, secondItem].sorted()
            #expect(items.count == 2)
            #expect(items[0].content == "Item B")
            #expect(items[1].content == "Item A")
        }

        @Test("Comparable order is as expected when priorities share the same date")
        func comparable_priority_order_is_expected() {
            let context = testContext
            let baseDate = shiftedDate("2000-01-01T12:00:00Z")
            let lowPriorityItem = try! Item.create(context: context,
                                                   date: baseDate,
                                                   content: "Item A",
                                                   income: 0,
                                                   outgo: 50,
                                                   category: "category",
                                                   priority: 0,
                                                   repeatID: UUID())
            let highPriorityItem = try! Item.create(context: context,
                                                    date: baseDate,
                                                    content: "Item B",
                                                    income: 100,
                                                    outgo: 0,
                                                    category: "category",
                                                    priority: 1,
                                                    repeatID: UUID())

            let items = [lowPriorityItem, highPriorityItem].sorted()
            #expect(items.count == 2)
            #expect(items[0].content == "Item A")
            #expect(items[1].content == "Item B")
        }

        @Test("Comparable order is consistent between priority 0/1 and 1/2")
        func comparable_priority_order_is_consistent() {
            let context = testContext
            let baseDate = shiftedDate("2000-01-01T12:00:00Z")
            let firstItem = try! Item.create(context: context,
                                             date: baseDate,
                                             content: "Item A",
                                             income: 0,
                                             outgo: 10,
                                             category: "category",
                                             priority: 1,
                                             repeatID: UUID())
            let secondItem = try! Item.create(context: context,
                                              date: baseDate,
                                              content: "Item B",
                                              income: 0,
                                              outgo: 20,
                                              category: "category",
                                              priority: 2,
                                              repeatID: UUID())

            let items = [firstItem, secondItem].sorted()
            #expect(items.count == 2)
            #expect(items[0].content == "Item A")
            #expect(items[1].content == "Item B")
        }

        @Test("Result is as expected when updating")
        func updating_is_expected() {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[1]
            try! item.modify(date: shiftedDate("2000-02-01T12:00:00Z"),
                             content: "content",
                             income: 300,
                             outgo: 100,
                             category: "category",
                             priority: 0,
                             repeatID: UUID())
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when updating first")
        func updating_first_is_expected() {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[0]
            try! item.modify(date: shiftedDate("2000-01-01T12:00:00Z"),
                             content: "content",
                             income: 300,
                             outgo: 100,
                             category: "category",
                             priority: 0,
                             repeatID: UUID())
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 200)
        }

        @Test("Result is as expected when updating last")
        func updating_last_is_expected() {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[4]
            try! item.modify(date: shiftedDate("2000-05-01T12:00:00Z"),
                             content: "content",
                             income: 300,
                             outgo: 100,
                             category: "category",
                             priority: 0,
                             repeatID: UUID())
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when changing order")
        func changing_order_is_expected() {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[4]
            try! item.modify(date: shiftedDate("1999-12-31T00:00:00Z"),
                             content: "content",
                             income: 300,
                             outgo: 100,
                             category: "category",
                             priority: 0,
                             repeatID: UUID())
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 200)
        }

        @Test("Result is as expected when deleting")
        func deleting_is_expected() {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[1]
            context.delete(item)
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 400)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when deleting first")
        func deleting_first_is_expected() {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[0]
            context.delete(item)
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 400)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when deleting last")
        func deleting_last_is_expected() {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(context: context,
                                            date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                                            content: "content",
                                            income: 200,
                                            outgo: 100,
                                            category: "category",
                                            priority: 0,
                                            repeatID: UUID())
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[4]
            context.delete(item)
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 400)
            #expect(last.balance == 100)
        }
    }
}
