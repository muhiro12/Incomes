//
//  GetPreviousItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUI

struct GetPreviousItemIntent: StaticPerformIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    struct Arguments {
        let date: Date
        let itemService: ItemService
    }

    static func perform(_ arguments: Arguments) throws -> Item? {
        try arguments.itemService.item(.items(.dateIsBefore(arguments.date)))
    }

    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try Self.perform(.init(date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: try .init(item))
    }
}

struct GetPreviousItemDateIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    func perform() throws -> some ReturnsValue<Date?> {
        guard let item = try GetPreviousItemIntent.perform(.init(date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: item.localDate)
    }
}

struct GetPreviousItemContentIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    func perform() throws -> some ReturnsValue<String?> {
        guard let item = try GetPreviousItemIntent.perform(.init(date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: item.content)
    }
}

struct GetPreviousItemProfitIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        guard let item = try GetPreviousItemIntent.perform(.init(date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .result(value: .init(amount: item.profit, currencyCode: currencyCode))
    }
}

struct ShowPreviousItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Previous Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let item = try GetPreviousItemIntent.perform(.init(date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}

struct ShowRecentItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Recent Item", table: "AppIntents")

    @Dependency private var itemService: ItemService

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let item = try GetPreviousItemIntent.perform(.init(date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}
