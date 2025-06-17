//
//  GetNextItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct GetNextItemsIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Next Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = [Item]?

    static func perform(_ input: Input) throws -> Output {
        let descriptor = FetchDescriptor.items(.dateIsAfter(input.date), order: .forward)
        guard let item = try input.context.fetchFirst(descriptor) else {
            return nil
        }
        return try input.context.fetch(.items(.dateIsSameDayAs(item.localDate)))
    }

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        guard let items = try Self.perform((context: modelContainer.mainContext, date: date)) else {
            return .result(value: .empty)
        }
        return .result(value: items.compactMap(ItemEntity.init))
    }
}
