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
            value: try ItemIntentRelativeItemSupport.entities(
                context: modelContainer.mainContext,
                date: date,
                direction: .next
            )
        )
    }
}
