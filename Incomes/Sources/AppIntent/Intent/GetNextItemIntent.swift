//
//  GetNextItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUI

struct GetNextItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    static func perform(date: Date,
                        itemService: ItemService) throws -> Item? {
        try itemService.item(.items(.dateIsAfter(date), order: .forward))
    }

    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try Self.perform(date: date, itemService: itemService) else {
            return .result(value: nil)
        }
        return .result(value: try .init(item))
    }
}

struct GetNextItemDateIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    func perform() throws -> some ReturnsValue<Date?> {
        guard let item = try GetNextItemIntent.perform(date: date, itemService: itemService) else {
            return .result(value: nil)
        }
        return .result(value: item.localDate)
    }
}

struct GetNextItemContentIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    func perform() throws -> some ReturnsValue<String?> {
        guard let item = try GetNextItemIntent.perform(date: date, itemService: itemService) else {
            return .result(value: nil)
        }
        return .result(value: item.content)
    }
}

struct GetNextItemProfitIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        guard let item = try GetNextItemIntent.perform(date: date, itemService: itemService) else {
            return .result(value: nil)
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .result(value: .init(amount: item.profit, currencyCode: currencyCode))
    }
}

struct ShowNextItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Next Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let item = try GetNextItemIntent.perform(date: date, itemService: itemService) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}

struct ShowUpcomingItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Upcoming Item", table: "AppIntents")

    @Dependency private var itemService: ItemService

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let item = try GetNextItemIntent.perform(date: date, itemService: itemService) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}
