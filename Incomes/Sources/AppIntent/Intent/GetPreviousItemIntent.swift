//
//  GetPreviousItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUI

struct GetPreviousItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = Item?

    static func perform(_ input: Input) throws -> Output {
        try input.itemService.item(.items(.dateIsBefore(input.date)))
    }

    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try Self.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: try .init(item))
    }
}

struct GetPreviousItemDateIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = Date?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetPreviousItemIntent.perform(input) else {
            return nil
        }
        return item.localDate
    }

    func perform() throws -> some ReturnsValue<Date?> {
        guard let item = try Self.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: item)
    }
}

struct GetPreviousItemContentIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = String?

    static func perform(_ input: Input) throws -> Output {
        try GetPreviousItemIntent.perform(input)?.content
    }

    func perform() throws -> some ReturnsValue<String?> {
        guard let content = try Self.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: content)
    }
}

struct GetPreviousItemProfitIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = IntentCurrencyAmount?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetPreviousItemIntent.perform(input) else {
            return nil
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .init(amount: item.profit, currencyCode: currencyCode)
    }

    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        guard let amount = try Self.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: amount)
    }
}

struct ShowPreviousItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Previous Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = Item?

    static func perform(_ input: Input) throws -> Output {
        try GetPreviousItemIntent.perform(input)
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let item = try Self.perform((date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}

struct ShowRecentItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Recent Item", table: "AppIntents")

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = Item?

    static func perform(_ input: Input) throws -> Output {
        try GetPreviousItemIntent.perform(input)
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let item = try Self.perform((date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}
