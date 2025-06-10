//
//  GetItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct GetItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    static func perform(date: Date,
                        itemService: ItemService) throws -> [Item] {
        try itemService.items(.items(.dateIsSameMonthAs(date)))
    }

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try Self.perform(date: date, itemService: itemService)
        return .result(value: try items.map { try .init($0) })
    }
}
