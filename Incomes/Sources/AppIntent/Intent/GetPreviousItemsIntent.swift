//
//  GetPreviousItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct GetPreviousItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(value: .empty)
        }
        let items = try itemService.items(.items(.dateIsSameDayAs(item.localDate)))
        return .result(value: try items.map { try .init($0) })
    }
}

struct ShowPreviousItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Previous Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        let items = try itemService.items(.items(.dateIsSameDayAs(item.localDate)))
        guard items.isNotEmpty else {
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

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        let items = try itemService.items(.items(.dateIsSameDayAs(item.localDate)))
        guard items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemListSection(items)
        }
    }
}
