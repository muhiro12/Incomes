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
            value: try sharedItemService.item(Item.descriptor(.dateIsAfter(date), order: .forward))?.date
        )
    }

    static func performGetNextItemContent(date: Date) async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(.dateIsAfter(date), order: .forward))?.content
        )
    }

    static func performGetNextItemProfit(date: Date) async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(.dateIsAfter(date), order: .forward))?.profit.asCurrency
        )
    }

    static func performShowNextItem(date: Date) async throws -> some IntentResult & ShowsSnippetView {
        guard let item = try sharedItemService.item(Item.descriptor(.dateIsAfter(date), order: .forward)) else {
            return .result()
        }
        return .result {
            incomesView {
                ListItem()
                    .environment(item)
            }
        }
    }

    // MARK: - Previous Item

    static func performGetPreviousItemDate(date: Date) async throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(.dateIsBefore(date)))?.date
        )
    }

    static func performGetPreviousItemContent(date: Date) async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(.dateIsBefore(date)))?.content
        )
    }

    static func performGetPreviousItemProfit(date: Date) async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(.dateIsBefore(date)))?.profit.asCurrency
        )
    }

    static func performShowPreviousItem(date: Date) async throws -> some IntentResult & ShowsSnippetView {
        guard let item = try sharedItemService.item(Item.descriptor(.dateIsBefore(date))) else {
            return .result()
        }
        return .result {
            incomesView {
                ListItem()
                    .environment(item)
            }
        }
    }

    // MARK: - Item List

    static func performShowItemList(date: Date) async throws -> some IntentResult & ShowsSnippetView {
        .result {
            incomesView {
                ItemListSection(Item.descriptor(.dateIsSameMonthAs(date)))
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
