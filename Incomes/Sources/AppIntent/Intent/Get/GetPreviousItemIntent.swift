//
//  GetPreviousItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct GetPreviousItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = ItemEntity?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try input.itemService.item(.items(.dateIsBefore(input.date))) else {
            return nil
        }
        return .init(item)
    }

    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try Self.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: item)
    }
}
