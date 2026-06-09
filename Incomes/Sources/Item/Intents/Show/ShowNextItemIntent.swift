//
//  ShowNextItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowNextItemIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Show Next Item", table: "AppIntents")

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let item = try ItemQueryOperations.nextItem(
            context: modelContainer.mainContext,
            date: date
        )
        return ItemIntentShowResultSupport.singleItem(
            item,
            defaultDate: date
        )
    }
}
