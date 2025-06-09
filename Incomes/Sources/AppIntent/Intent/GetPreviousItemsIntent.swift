//
//  GetPreviousItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct GetPreviousItemsIntent: StaticPerformIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    struct Arguments {
        let date: Date
        let itemService: ItemService
    }

    static func perform(_ arguments: Arguments) throws -> [Item]? {
        guard let item = try arguments.itemService.item(.items(.dateIsBefore(arguments.date))) else {
            return nil
        }
        return try arguments.itemService.items(.items(.dateIsSameDayAs(item.localDate)))
    }

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        guard let items = try Self.perform(.init(date: date, itemService: itemService)) else {
            return .result(value: .empty)
        }
        return .result(value: try items.map { try .init($0) })
    }
}

struct ShowPreviousItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Previous Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let items = try GetPreviousItemsIntent.perform(.init(date: date, itemService: itemService)),
              items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemListSection(items)
        }
    }
}

struct ShowRecentItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Recent Items", table: "AppIntents")

    @Dependency private var itemService: ItemService

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let items = try GetPreviousItemsIntent.perform(.init(date: date, itemService: itemService)),
              items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemListSection(items)
        }
    }
}
