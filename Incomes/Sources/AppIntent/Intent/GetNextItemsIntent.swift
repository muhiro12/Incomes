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
        .result(
            value: try {
                guard let item = try itemService.item(.items(.dateIsAfter(date), order: .forward)) else {
                    return .empty
                }
                return try itemService.items(.items(.dateIsSameDayAs(item.localDate))).map { item in
                    try .init(item)
                }
            }()
        )
    }
}

struct ShowNextItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Next Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let items = try GetNextItemsIntent().perform().value,
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
