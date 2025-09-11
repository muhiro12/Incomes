//
//  BalanceCalculatorTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

@testable import IncomesLibrary
import Testing

struct BalanceCalculatorTests {
    @Test
    func testCalculate() {
        // inserting
        do {
            let context = testContext
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
                context.insert(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = try! Item.create(
                context: context,
                date: shiftedDate("2000-01-31T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatID: UUID()
            )
            context.insert(item)
            try! BalanceCalculator.calculate(in: context, after: item.localDate)

            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        // inserting first
        do {
            let context = testContext
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
                context.insert(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = try! Item.create(
                context: context,
                date: shiftedDate("2001-01-01T00:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatID: UUID()
            )
            context.insert(item)
            try! BalanceCalculator.calculate(in: context, after: item.localDate)

            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        // inserting last
        do {
            let context = testContext
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
                context.insert(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = try! Item.create(
                context: context,
                date: shiftedDate("2000-01-01T00:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatID: UUID()
            )
            context.insert(item)
            try! BalanceCalculator.calculate(in: context, after: item.localDate)

            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        // updating
        do {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[1]
            try! item.modify(
                date: shiftedDate("2000-02-01T12:00:00Z"),
                content: "content",
                income: 300,
                outgo: 100,
                category: "category",
                repeatID: UUID()
            )
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        // updating first
        do {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[0]
            try! item.modify(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 300,
                outgo: 100,
                category: "category",
                repeatID: UUID()
            )
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 200)
        }

        // updating last
        do {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[4]
            try! item.modify(
                date: shiftedDate("2000-05-01T12:00:00Z"),
                content: "content",
                income: 300,
                outgo: 100,
                category: "category",
                repeatID: UUID()
            )
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        // changing order
        do {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
                context.insert(item)
                items.append(item)
            }
            try! BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[4]
            try! item.modify(
                date: shiftedDate("1999-12-31T00:00:00Z"),
                content: "content",
                income: 300,
                outgo: 100,
                category: "category",
                repeatID: UUID()
            )
            try! BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = fetchItems(context).first!
            let last = fetchItems(context).last!
            #expect(first.balance == 600)
            #expect(last.balance == 200)
        }

        // deleting
        do {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
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

        // deleting first
        do {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
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

        // deleting last
        do {
            let context = testContext
            var items: [Item] = []
            for i in 1...5 {
                let item = try! Item.create(
                    context: context,
                    date: shiftedDate("2000-0\(i)-01T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    repeatID: UUID()
                )
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
