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
        .result(
            value: try {
                guard let item = try itemService.item(.items(.dateIsAfter(date), order: .forward)) else {
                    return nil
                }
                return try .init(item)
            }()
        )
    }
}

struct GetNextItemDateIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        .result(
            value: try itemService.item(.items(.dateIsAfter(date), order: .forward))?.localDate
        )
    }
}

struct GetNextItemContentIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsAfter(date), order: .forward))?.content
        )
    }
}

struct GetNextItemProfitIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsAfter(date), order: .forward))?.profit.asCurrency
        )
    }
}
