//
//  GetNextItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct GetNextItemsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    static func perform(date: Date,
                        itemService: ItemService) throws -> [Item]? {
        guard let item = try itemService.item(.items(.dateIsAfter(date), order: .forward)) else {
            return nil
        }
        return try itemService.items(.items(.dateIsSameDayAs(item.localDate)))
    }

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        guard let items = try Self.perform(date: date, itemService: itemService) else {
            return .result(value: .empty)
        }
        return .result(value: try items.map { try .init($0) })
    }
}
