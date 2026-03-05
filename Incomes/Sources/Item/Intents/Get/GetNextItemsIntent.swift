//
//  GetNextItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//

import AppIntents
import SwiftData

struct GetNextItemsIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Next Items", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        .result(
            value: try ItemService.nextItems(
                context: modelContainer.mainContext,
                date: date
            ).compactMap(ItemEntity.init) // swiftlint:disable:this multiline_function_chains
        )
    }
}
