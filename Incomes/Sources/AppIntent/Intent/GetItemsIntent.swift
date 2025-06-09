//
//  GetItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct GetItemsIntent: StaticPerformIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    struct Arguments {
        let date: Date
        let itemService: ItemService
    }

    static func perform(_ arguments: Arguments) throws -> [Item] {
        try arguments.itemService.items(.items(.dateIsSameMonthAs(arguments.date)))
    }

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try Self.perform(.init(date: date, itemService: itemService))
        return .result(value: try items.map { try .init($0) })
    }
}

struct ShowItemsIntent: StaticPerformIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    struct Arguments {
        let date: Date
        let itemService: ItemService
    }

    static func perform(_ arguments: Arguments) throws -> [Item]? {
        let items = try arguments.itemService.items(.items(.dateIsSameMonthAs(arguments.date)))
        return items.isEmpty ? nil : items
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let items = try Self.perform(.init(date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemListSection(items)
        }
    }
}

struct ShowThisMonthItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show This Month's Items", table: "AppIntents")

    @Dependency private var itemService: ItemService

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let items = try ShowItemsIntent.perform(.init(date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemListSection(items)
        }
    }
}

struct ShowChartsIntent: StaticPerformIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Charts", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService
    @Dependency private var modelContainer: ModelContainer

    struct Arguments {
        let date: Date
        let itemService: ItemService
    }

    static func perform(_ arguments: Arguments) throws -> [Item]? {
        let date = arguments.date
        let itemService = arguments.itemService
        let items = try itemService.items(.items(.dateIsSameMonthAs(date)))
        return items.isEmpty ? nil : items
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let items = try Self.perform(.init(date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }
}

struct ShowThisMonthChartsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show This Month's Charts", table: "AppIntents")

    @Dependency private var itemService: ItemService
    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let items = try ShowChartsIntent.perform(.init(date: date, itemService: itemService)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }
}
