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
    static let title: LocalizedStringResource = .init("Get Previous Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.localDate
        )
    }
}

struct GetPreviousItemContentIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.content
        )
    }
}

struct GetPreviousItemProfitIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.profit.asCurrency
        )
    }
}
