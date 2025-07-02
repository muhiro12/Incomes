//
//  GetItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct GetItemsIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = [ItemEntity]

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Items", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let items = try input.context.fetch(
            .items(.dateIsSameMonthAs(input.date))
        )
        return items.compactMap(ItemEntity.init)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try Self.perform((context: modelContainer.mainContext, date: date))
        return .result(value: items)
    }
}
