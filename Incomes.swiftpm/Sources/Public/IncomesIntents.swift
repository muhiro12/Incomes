//
//  IncomesIntents.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/6/24.
//

import AppIntents
import SwiftData
import SwiftUI

@MainActor
public enum IncomesIntents {
    private static let sharedModelContainer: ModelContainer = try! .init(
        for: Item.self,
        configurations: .init(
            url: .applicationSupportDirectory.appendingPathComponent("Incomes.sqlite"),
            cloudKitDatabase: AppStorage(.isICloudOn).wrappedValue ? .automatic : .none
        )
    )
    private static let sharedItemService: ItemService = .init(context: sharedModelContainer.mainContext)
    private static let sharedTagService: TagService = .init(context: sharedModelContainer.mainContext)
    private static let sharedConfigurationService: ConfigurationService = .init()
    private static let sharedNotificationService: NotificationService = .init()
}

// MARK: - Perform

public extension IncomesIntents {
    // MARK: - Open

    static func performOpenIncomes() async throws -> some IntentResult {
        .result()
    }

    // MARK: - Next Item

    static func performGetNextItemDate(date: Date) async throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try sharedItemService.item(.items(.dateIsAfter(date), order: .forward))?.date
        )
    }

    static func performGetNextItemContent(date: Date) async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(.items(.dateIsAfter(date), order: .forward))?.content
        )
    }

    static func performGetNextItemProfit(date: Date) async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(.items(.dateIsAfter(date), order: .forward))?.profit.asCurrency
        )
    }

    static func performShowNextItems(date: Date) async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let item = try sharedItemService.item(.items(.dateIsAfter(date), order: .forward)) else {
            return .result(dialog: .init("Not Found"))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            incomesView {
                ItemListSection(.items(.dateIsSameDayAs(item.date)))
            }
        }
    }

    // MARK: - Previous Item

    static func performGetPreviousItemDate(date: Date) async throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try sharedItemService.item(.items(.dateIsBefore(date)))?.date
        )
    }

    static func performGetPreviousItemContent(date: Date) async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(.items(.dateIsBefore(date)))?.content
        )
    }

    static func performGetPreviousItemProfit(date: Date) async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(.items(.dateIsBefore(date)))?.profit.asCurrency
        )
    }

    static func performShowPreviousItems(date: Date) async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let item = try sharedItemService.item(.items(.dateIsBefore(date))) else {
            return .result(dialog: .init("Not Found"))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            incomesView {
                ItemListSection(.items(.dateIsSameDayAs(item.date)))
            }
        }
    }

    // MARK: - Item List

    static func performShowItems(date: Date) async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            incomesView {
                ItemListSection(.items(.dateIsSameMonthAs(date)))
            }
        }
    }

    static func performShowCharts(date: Date) async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            incomesView {
                ChartSections(.items(.dateIsSameMonthAs(date)))
            }
        }
    }
}

// MARK: - Private

private extension IncomesIntents {
    static func incomesView(content: () -> some View) -> some View {
        content()
            .safeAreaPadding()
            .modelContainer(sharedModelContainer)
            .environment(sharedItemService)
            .environment(sharedTagService)
            .environment(sharedConfigurationService)
            .environment(sharedNotificationService)
            .incomesEnvironment(
                googleMobileAds: { _ in EmptyView() },
                licenseList: { EmptyView() },
                storeKit: { EmptyView() }
            )
    }
}
