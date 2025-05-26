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
        guard let item = try itemService.item(.items(.dateIsBefore(date))).map({ item in
            try ItemEntity(item)
        }) else {
            return .result(value: nil)
        }
        return .result(value: item)
    }
}

struct GetPreviousItemDateIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        .result(
            value: try GetPreviousItemIntent().perform().value??.date
        )
    }
}

struct GetPreviousItemContentIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try GetPreviousItemIntent().perform().value??.content
        )
    }
}

struct GetPreviousItemProfitIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try GetPreviousItemIntent().perform().value??.profit.asCurrency
        )
    }
}
