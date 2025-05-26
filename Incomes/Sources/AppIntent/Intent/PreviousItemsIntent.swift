//
//  PreviousItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct GetPreviousItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        .result(
            value: try {
                guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
                    return .empty
                }
                return try itemService.items(.items(.dateIsSameDayAs(item.localDate))).map { item in
                    try .init(item)
                }
            }()
        )
    }
}

struct ShowPreviousItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Previous Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let items = try GetPreviousItemsIntent().perform().value,
              items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            // TODO: Modify interface of IntentsItemListSection to set [ItemEntity]
            IntentsItemListSection(.items(.dateIsSameDayAs(items[0].date)))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}
