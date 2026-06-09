//
//  ShowRecentItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowRecentItemsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Show Recent Items", table: "AppIntents")

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        return try ItemIntentShowResultSupport.relativeItemList(
            modelContainer: modelContainer,
            date: date,
            direction: .previous
        )
    }
}
