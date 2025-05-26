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
    static let title: LocalizedStringResource = .init("Get Previous Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(value: nil)
        }
        return .result(value: try .init(item))
    }
}

struct GetPreviousItemDateIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(value: nil)
        }
        return .result(value: item.localDate)
    }
}

struct GetPreviousItemContentIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(value: nil)
        }
        return .result(value: item.content)
    }
}

struct GetPreviousItemProfitIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(value: nil)
        }
        return .result(value: item.profit.asCurrency)
    }
}

struct ShowPreviousItemIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Previous Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemSection()
                .safeAreaPadding()
                .environment(item)
        }
    }
}
