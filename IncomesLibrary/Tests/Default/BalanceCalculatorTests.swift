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
    @Test("Result is as expected when inserting")
    func inserting_is_expected() {
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

    @Test("Result is as expected when inserting first")
    func inserting_first_is_expected() {
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

    @Test("Result is as expected when inserting last")
    func inserting_last_is_expected() {
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

    @Test("Result is as expected when updating")
    func updating_is_expected() {
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

    @Test("Result is as expected when updating first")
    func updating_first_is_expected() {
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

    @Test("Result is as expected when updating last")
    func updating_last_is_expected() {
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

    @Test("Result is as expected when changing order")
    func changing_order_is_expected() {
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

    @Test("Result is as expected when deleting")
    func deleting_is_expected() {
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

    @Test("Result is as expected when deleting first")
    func deleting_first_is_expected() {
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

    @Test("Result is as expected when deleting last")
    func deleting_last_is_expected() {
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
