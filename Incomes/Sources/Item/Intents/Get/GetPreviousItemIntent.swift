//
//  GetPreviousItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//

import AppIntents
import SwiftData

struct GetPreviousItemIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Previous Item", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<ItemEntity?> {
        .result(
            value: try ItemIntentRelativeItemSupport.entity(
                context: modelContainer.mainContext,
                date: date,
                direction: .previous
            )
        )
    }
}
