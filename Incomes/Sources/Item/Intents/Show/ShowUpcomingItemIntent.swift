//
//  ShowUpcomingItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowUpcomingItemIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Show Upcoming Item", table: "AppIntents")

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        let item = try ItemRelativeQueryCoordinator.item(
            context: modelContainer.mainContext,
            date: date,
            direction: .next
        )
        return ItemIntentShowResultSupport.singleItem(
            item,
            defaultDate: date
        )
    }
}
