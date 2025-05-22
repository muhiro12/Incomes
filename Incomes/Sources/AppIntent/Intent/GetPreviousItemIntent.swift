//
//  GetPreviousItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct GetPreviousItemIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Previous Item")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<ItemEntity?> {
        .result(
            value: try {
                guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
                    return nil
                }
                return try .init(item)
            }()
        )
    }
}

struct GetPreviousItemDateIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Previous Item Date")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.localDate
        )
    }
}

struct GetPreviousItemContentIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Previous Item Content")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.content
        )
    }
}

struct GetPreviousItemProfitIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Previous Item Profit")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.profit.asCurrency
        )
    }
}

struct ShowPreviousItemsIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Show Previous Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(dialog: .init("Not Found"))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentsItemListSection(.items(.dateIsSameDayAs(item.localDate)))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}
