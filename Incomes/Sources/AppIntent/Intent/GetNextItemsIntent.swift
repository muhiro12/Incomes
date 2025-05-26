//
//  GetNextItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct GetNextItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        guard let item = try itemService.item(.items(.dateIsAfter(date), order: .forward)) else {
            return .result(value: .empty)
        }
        let items = try itemService.items(.items(.dateIsSameDayAs(item.localDate)))
        return .result(value: try items.map { try .init($0) })
    }
}

struct ShowNextItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Next Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let item = try itemService.item(.items(.dateIsAfter(date), order: .forward)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        let items = try itemService.items(.items(.dateIsSameDayAs(item.localDate)))
        guard items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentsItemListSection(.items(.idsAre(items.map(\.id))))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}
