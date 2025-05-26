//
//  CreateItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct CreateItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Create Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date
    @Parameter(title: "Content")
    private var content: String
    @Parameter(title: "Income")
    private var income: Double
    @Parameter(title: "Outgo")
    private var outgo: Double
    @Parameter(title: "Category")
    private var category: String
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60))
    private var repeatCount: Int

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<ItemEntity> {
        let item = try itemService.create(
            date: date,
            content: content,
            income: .init(income),
            outgo: .init(outgo),
            category: category,
            repeatCount: repeatCount
        )
        return .result(value: try .init(item))
    }
}

struct CreateAndShowItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Create and Show Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date
    @Parameter(title: "Content")
    private var content: String
    @Parameter(title: "Income")
    private var income: Double
    @Parameter(title: "Outgo")
    private var outgo: Double
    @Parameter(title: "Category")
    private var category: String
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60))
    private var repeatCount: Int

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let item = try itemService.create(
            date: date,
            content: content,
            income: .init(income),
            outgo: .init(outgo),
            category: category,
            repeatCount: repeatCount
        )
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .safeAreaPadding()
                .environment(item)
        }
    }
}
