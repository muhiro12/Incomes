//
//  IncomesIntents.swift
//  Incomes
//
//  Created by Hiromu Nakano on 9/5/24.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUI

// MARK: - Open

struct OpenIncomesIntent: AppIntent {
    static var title = LocalizedStringResource("Open Incomes")
    static var openAppWhenRun = true

    @MainActor
    func perform() throws -> some IntentResult {
        .result()
    }
}

// MARK: - Next Item

struct GetNextItem: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Next Item")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<ItemEntity?> {
        .result(
            value: try {
                guard let item = try itemService.item(.items(.dateIsAfter(date), order: .forward)) else {
                    return nil
                }
                return try .init(item)
            }()
        )
    }
}

struct GetNextItemDate: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Next Item Date")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try itemService.item(.items(.dateIsAfter(date), order: .forward))?.localDate
        )
    }
}

struct GetNextItemContent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Next Item Content")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsAfter(date), order: .forward))?.content
        )
    }
}

struct GetNextItemProfit: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Next Item Profit")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsAfter(date), order: .forward))?.profit.asCurrency
        )
    }
}

struct ShowNextItemsIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Show Next Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let item = try itemService.item(.items(.dateIsAfter(date), order: .forward)) else {
            return .result(dialog: .init("Not Found"))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentsItemListSection(.items(.dateIsSameDayAs(item.localDate)))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}

// MARK: - Previous Item

struct GetPreviousItem: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Previous Item")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<ItemEntity?> {
        .result(
            value: try {
                guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
                    return nil
                }
                return try .init(item)
            }()
        )
    }
}

struct GetPreviousItemDate: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Previous Item Date")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.localDate
        )
    }
}

struct GetPreviousItemContent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Previous Item Content")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.content
        )
    }
}

struct GetPreviousItemProfit: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Get Previous Item Profit")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.profit.asCurrency
        )
    }
}

struct ShowPreviousItemsIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Show Previous Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(dialog: .init("Not Found"))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentsItemListSection(.items(.dateIsSameDayAs(item.localDate)))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}

// MARK: - Item List

struct ShowItemsIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Show Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentsItemListSection(.items(.dateIsSameMonthAs(date)))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}

struct ShowChartsIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Show Charts")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            ChartSectionGroup(.items(.dateIsSameMonthAs(date)))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}

// MARK: - Private

private struct IntentsItemListSection: View {
    @Query private var items: [Item]

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = Query(descriptor)
    }

    var body: some View {
        Section {
            ForEach(items) {
                NarrowListItem()
                    .environment($0)
            }
        }
    }
}
