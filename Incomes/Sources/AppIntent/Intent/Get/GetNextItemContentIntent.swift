//
//  GetNextItemContentIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUtilities

struct GetNextItemContentIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Next Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = String?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetNextItemIntent.perform((date: input.date, itemService: input.itemService)) else {
            return nil
        }
        return item.content
    }

    func perform() throws -> some ReturnsValue<String?> {
        guard let item = try GetNextItemIntent.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: item.content)
    }
}
