//
//  GetItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUtilities

struct GetItemsIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = [Item]

    static func perform(_ input: Input) throws -> Output {
        try input.itemService.items(.items(.dateIsSameMonthAs(input.date)))
    }

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try Self.perform((date: date, itemService: itemService))
        return .result(value: items.compactMap(ItemEntity.init))
    }
}
