//
//  GetItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct GetItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try itemService.items(.items(.dateIsSameMonthAs(date)))
        return .result(value: try items.map { try .init($0) })
    }
}

struct ShowItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let items = try itemService.items(.items(.dateIsSameMonthAs(date)))
        guard items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentsItemListSection(items)
                .safeAreaPadding()
        }
    }
}

struct ShowChartsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Charts", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let items = try itemService.items(.items(.dateIsSameMonthAs(date)))
        guard items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}
