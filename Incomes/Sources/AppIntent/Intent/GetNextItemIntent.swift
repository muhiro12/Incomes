//
//  GetNextItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUI

struct GetNextItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = Item?

    static func perform(_ input: Input) throws -> Output {
        try input.itemService.item(.items(.dateIsAfter(input.date), order: .forward))
    }

    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try Self.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: try .init(item))
    }
}

struct GetNextItemDateIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = Date?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetNextItemIntent.perform((date: input.date, itemService: input.itemService)) else {
            return nil
        }
        return item.localDate
    }

    func perform() throws -> some ReturnsValue<Date?> {
        guard let item = try GetNextItemIntent.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: item.localDate)
    }
}

struct GetNextItemContentIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = String?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetNextItemIntent.perform((date: input.date, itemService: input.itemService)) else {
            return nil
        }
        return item.content
    }

    func perform() throws -> some ReturnsValue<String?> {
        guard let item = try GetNextItemIntent.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: item.content)
    }
}

struct GetNextItemProfitIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = IntentCurrencyAmount?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetNextItemIntent.perform((date: input.date, itemService: input.itemService)) else {
            return nil
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .init(amount: item.profit, currencyCode: currencyCode)
    }

    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        guard let item = try GetNextItemIntent.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .result(value: .init(amount: item.profit, currencyCode: currencyCode))
    }
}

struct ShowNextItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Next Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = Item?

    static func perform(_ input: Input) throws -> Output {
        try GetNextItemIntent.perform((date: input.date, itemService: input.itemService))
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let item = try GetNextItemIntent.perform((date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}

struct ShowUpcomingItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Upcoming Item", table: "AppIntents")

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = Item?

    static func perform(_ input: Input) throws -> Output {
        try GetNextItemIntent.perform((date: input.date, itemService: input.itemService))
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let item = try GetNextItemIntent.perform((date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}
