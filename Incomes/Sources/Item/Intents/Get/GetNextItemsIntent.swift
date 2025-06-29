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
    typealias Input = (container: ModelContainer, date: Date)
    typealias Output = [ItemEntity]

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Next Items", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let descriptor = FetchDescriptor.items(.dateIsAfter(input.date), order: .forward)
        guard let item = try input.container.mainContext.fetchFirst(descriptor) else {
            return .empty
        }
        let items = try input.container.mainContext.fetch(
            .items(.dateIsSameDayAs(item.localDate))
        )
        return items.compactMap(ItemEntity.init)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try Self.perform(
            (container: modelContainer, date: date)
        )
        return .result(value: items)
    }
}
