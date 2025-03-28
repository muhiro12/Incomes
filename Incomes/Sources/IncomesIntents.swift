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
public enum IncomesIntents {}

// MARK: - Perform

public extension IncomesIntents {
    // MARK: - Open

    static func performOpenIncomes() throws -> some IntentResult {
        .result()
    }

    // MARK: - Next Item

    static func performGetNextItemDate(date: Date) throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try itemService.item(.items(.dateIsAfter(date), order: .forward))?.date
        )
    }

    static func performGetNextItemContent(date: Date) throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsAfter(date), order: .forward))?.content
        )
    }

    static func performGetNextItemProfit(date: Date) throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsAfter(date), order: .forward))?.profit.asCurrency
        )
    }

    static func performShowNextItems(date: Date) throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let item = try itemService.item(.items(.dateIsAfter(date), order: .forward)) else {
            return .result(dialog: .init("Not Found"))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            incomesView {
                ItemListSection(.items(.dateIsSameDayAs(item.date)))
            }
        }
    }

    // MARK: - Previous Item

    static func performGetPreviousItemDate(date: Date) throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.date
        )
    }

    static func performGetPreviousItemContent(date: Date) throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.content
        )
    }

    static func performGetPreviousItemProfit(date: Date) throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try itemService.item(.items(.dateIsBefore(date)))?.profit.asCurrency
        )
    }

    static func performShowPreviousItems(date: Date) throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let item = try itemService.item(.items(.dateIsBefore(date))) else {
            return .result(dialog: .init("Not Found"))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            incomesView {
                ItemListSection(.items(.dateIsSameDayAs(item.date)))
            }
        }
    }

    // MARK: - Item List

    static func performShowItems(date: Date) throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            incomesView {
                ItemListSection(.items(.dateIsSameMonthAs(date)))
            }
        }
    }

    static func performShowCharts(date: Date) throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            incomesView {
                ChartSectionGroup(.items(.dateIsSameMonthAs(date)))
            }
        }
    }
}

// MARK: - Private

private extension IncomesIntents {
    static let modelContainer: ModelContainer = try! .init(
        for: Item.self,
        configurations: .init(
            url: .applicationSupportDirectory.appendingPathComponent("Incomes.sqlite"),
            cloudKitDatabase: AppStorage(.isICloudOn).wrappedValue ? .automatic : .none
        )
    )
    static let itemService: ItemService = .init(context: modelContainer.mainContext)
    static let tagService: TagService = .init(context: modelContainer.mainContext)
    static let configurationService: ConfigurationService = .init()
    static let notificationService: NotificationService = .init()

    static func incomesView(content: () -> some View) -> some View {
        content()
            .safeAreaPadding()
            .modelContainer(modelContainer)
            .environment(itemService)
            .environment(tagService)
            .environment(configurationService)
            .environment(notificationService)
            .incomesEnvironment(
                googleMobileAds: { _ in EmptyView() },
                licenseList: { EmptyView() },
                storeKit: { EmptyView() },
                appIntents: { EmptyView() }
            )
    }
}
