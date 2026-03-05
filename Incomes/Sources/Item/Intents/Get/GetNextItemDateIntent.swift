//
//  GetNextItemDateIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct GetNextItemDateIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Next Item Date", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        .result(
            value: try ItemService.nextItemDate(
                context: modelContainer.mainContext,
                date: date
            )
        )
    }
}
