//
//  GetPreviousItemDateIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct GetPreviousItemDateIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = Date?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetPreviousItemIntent.perform(input) else {
            return nil
        }
        return item.date
    }

    func perform() throws -> some ReturnsValue<Date?> {
        guard let item = try Self.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: item)
    }
}
