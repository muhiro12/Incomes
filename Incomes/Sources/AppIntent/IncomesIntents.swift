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

struct GetNextItemDate: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Date")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try IncomesIntents.itemService.item(.items(.dateIsAfter(date), order: .forward))?.date
        )
    }
}

struct GetNextItemContent: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Content")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try IncomesIntents.itemService.item(.items(.dateIsAfter(date), order: .forward))?.content
        )
    }
}

struct GetNextItemProfit: AppIntent {
    static var title = LocalizedStringResource("Get Next Item Profit")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try IncomesIntents.itemService.item(.items(.dateIsAfter(date), order: .forward))?.profit.asCurrency
        )
    }
}

struct ShowNextItemsIntent: AppIntent {
    static var title = LocalizedStringResource("Show Next Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let item = try IncomesIntents.itemService.item(.items(.dateIsAfter(date), order: .forward)) else {
            return .result(dialog: .init("Not Found"))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IncomesIntents.incomesView {
                IntentsItemListSection(.items(.dateIsSameDayAs(item.date)))
            }
        }
    }
}

// MARK: - Previous Item

struct GetPreviousItemDate: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Date")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try IncomesIntents.itemService.item(.items(.dateIsBefore(date)))?.date
        )
    }
}

struct GetPreviousItemContent: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Content")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try IncomesIntents.itemService.item(.items(.dateIsBefore(date)))?.content
        )
    }
}

struct GetPreviousItemProfit: AppIntent {
    static var title = LocalizedStringResource("Get Previous Item Profit")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try IncomesIntents.itemService.item(.items(.dateIsBefore(date)))?.profit.asCurrency
        )
    }
}

struct ShowPreviousItemsIntent: AppIntent {
    static var title = LocalizedStringResource("Show Previous Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let item = try IncomesIntents.itemService.item(.items(.dateIsBefore(date))) else {
            return .result(dialog: .init("Not Found"))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IncomesIntents.incomesView {
                IntentsItemListSection(.items(.dateIsSameDayAs(item.date)))
            }
        }
    }
}

// MARK: - Item List

struct ShowItemsIntent: AppIntent {
    static var title = LocalizedStringResource("Show Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IncomesIntents.incomesView {
                IntentsItemListSection(.items(.dateIsSameMonthAs(date)))
            }
        }
    }
}

struct ShowChartsIntent: AppIntent {
    static var title = LocalizedStringResource("Show Charts")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IncomesIntents.incomesView {
                ChartSectionGroup(.items(.dateIsSameMonthAs(date)))
            }
        }
    }
}

// MARK: - Private

@MainActor
private enum IncomesIntents {
    static let modelContainer: ModelContainer = try! .init(
        for: Item.self,
        configurations: .init(
            url: .applicationSupportDirectory.appendingPathComponent("Incomes.sqlite"),
            cloudKitDatabase: AppStorage(.isICloudOn).wrappedValue ? .automatic : .none
        )
    )
    static let itemService: ItemService = .init(context: modelContainer.mainContext)
    static let tagService: TagService = .init(context: modelContainer.mainContext)
    static let notificationService: NotificationService = .init(itemService: itemService)
    static let configurationService: ConfigurationService = .init()

    static func incomesView(content: () -> some View) -> some View {
        content()
            .safeAreaPadding()
            .modelContainer(modelContainer)
            .environment(itemService)
            .environment(tagService)
            .environment(notificationService)
            .environment(configurationService)
            .incomesEnvironment(
                googleMobileAds: { _ in EmptyView() },
                licenseList: { EmptyView() },
                storeKit: { EmptyView() },
                appIntents: { EmptyView() }
            )
    }
}

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
