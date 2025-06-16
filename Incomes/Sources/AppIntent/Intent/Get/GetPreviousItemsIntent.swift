//
//  GetPreviousItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUtilities

struct GetPreviousItemsIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = [Item]?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try input.itemService.item(.items(.dateIsBefore(input.date))) else {
            return nil
        }
        return try input.itemService.items(.items(.dateIsSameDayAs(item.localDate)))
    }

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        guard let items = try Self.perform((date: date, itemService: itemService)) else {
            return .result(value: .empty)
        }
        return .result(value: items.compactMap(ItemEntity.init))
    }
}
