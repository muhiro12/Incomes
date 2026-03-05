//
//  GetPreviousItemContentIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct GetPreviousItemContentIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Previous Item Content", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try ItemService.previousItemContent(
                context: modelContainer.mainContext,
                date: date
            )
        )
    }
}
