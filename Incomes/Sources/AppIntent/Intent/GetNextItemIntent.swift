//
//  GetNextItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct GetNextItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try itemService.item(.items(.dateIsAfter(date), order: .forward)).map({ item in
            try ItemEntity(item)
        }) else {
            return .result(value: nil)
        }
        return .result(value: item)
    }
}

struct GetNextItemDateIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        .result(
            value: try GetNextItemIntent().perform().value??.date
        )
    }
}

struct GetNextItemContentIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try GetNextItemIntent().perform().value??.content
        )
    }
}

struct GetNextItemProfitIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try GetNextItemIntent().perform().value??.profit.asCurrency
        )
    }
}

struct ShowNextItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Next Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let id = try GetNextItemIntent().perform().value??.id else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        let item = try itemService.item(.items(.idIs(.init(base64Encoded: id))))
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemSection()
                .safeAreaPadding()
                .environment(item)
                .modelContainer(modelContainer)
        }
    }
}
