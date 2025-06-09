//
//  CreateItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct CreateItemIntent: StaticPerformIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Create Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date
    @Parameter(title: "Content")
    private var content: String
    @Parameter(title: "Income")
    private var income: Double
    @Parameter(title: "Outgo")
    private var outgo: Double
    @Parameter(title: "Category")
    private var category: String
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60))
    private var repeatCount: Int

    @Dependency private var itemService: ItemService

    struct Arguments {
        let date: Date
        let content: String
        let income: Double
        let outgo: Double
        let category: String
        let repeatCount: Int
        let itemService: ItemService
    }

    static func perform(_ arguments: Arguments) throws -> Item {
        let date = arguments.date
        let content = arguments.content
        let income = arguments.income
        let outgo = arguments.outgo
        let category = arguments.category
        let repeatCount = arguments.repeatCount
        let itemService = arguments.itemService
        guard content.isNotEmpty else {
            throw DebugError.default
        }
        return try itemService.create(
            date: date,
            content: content,
            income: .init(income),
            outgo: .init(outgo),
            category: category,
            repeatCount: repeatCount
        )
    }

    func perform() throws -> some ReturnsValue<ItemEntity> {
        let item = try Self.perform(
            .init(date: date,
                  content: content,
                  income: income,
                  outgo: outgo,
                  category: category,
                  repeatCount: repeatCount,
                  itemService: itemService)
        )
        return .result(value: try .init(item))
    }
}

struct CreateAndShowItemIntent: StaticPerformIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Create and Show Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date
    @Parameter(title: "Content")
    private var content: String
    @Parameter(title: "Income")
    private var income: Double
    @Parameter(title: "Outgo")
    private var outgo: Double
    @Parameter(title: "Category")
    private var category: String
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60))
    private var repeatCount: Int

    @Dependency private var itemService: ItemService

    struct Arguments {
        let date: Date
        let content: String
        let income: Double
        let outgo: Double
        let category: String
        let repeatCount: Int
        let itemService: ItemService
    }

    static func perform(_ arguments: Arguments) throws -> Item {
        let date = arguments.date
        let content = arguments.content
        let income = arguments.income
        let outgo = arguments.outgo
        let category = arguments.category
        let repeatCount = arguments.repeatCount
        let itemService = arguments.itemService
        guard content.isNotEmpty else {
            throw DebugError.default
        }
        return try itemService.create(
            date: date,
            content: content,
            income: .init(income),
            outgo: .init(outgo),
            category: category,
            repeatCount: repeatCount
        )
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let item = try Self.perform(
            .init(date: date,
                  content: content,
                  income: income,
                  outgo: outgo,
                  category: category,
                  repeatCount: repeatCount,
                  itemService: itemService)
        )
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}
