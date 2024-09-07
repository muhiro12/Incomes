//
//  IncomesIntent.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/6/24.
//

import AppIntents
import SwiftData
import SwiftUI

@MainActor
public enum IncomesIntent {
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

public extension IncomesIntent {
    // MARK: - Open

    static func performOpenIncomes() async throws -> some IntentResult {
        .result()
    }

    // MARK: - Next Item

    static func performGetNextItemDate() async throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(dateIsAfter: .now, order: .forward))?.date
        )
    }

    static func performGetNextItemContent() async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(dateIsAfter: .now, order: .forward))?.content
        )
    }

    static func performGetNextItemProfit() async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(dateIsAfter: .now, order: .forward))?.profit.asCurrency
        )
    }

    static func performShowNextItem() async throws -> some IntentResult & ShowsSnippetView {
        guard let item = try sharedItemService.item(Item.descriptor(dateIsAfter: .now, order: .forward)) else {
            return .result()
        }
        return .result(
            view: incomesView(
                ListItem(of: item)
            )
        )
    }

    // MARK: - Previous Item

    static func performGetPreviousItemDate() async throws -> some IntentResult & ReturnsValue<Date?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(dateIsBefore: .now))?.date
        )
    }

    static func performGetPreviousItemContent() async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(dateIsBefore: .now))?.content
        )
    }

    static func performGetPreviousItemProfit() async throws -> some IntentResult & ReturnsValue<String?> {
        .result(
            value: try sharedItemService.item(Item.descriptor(dateIsBefore: .now))?.profit.asCurrency
        )
    }

    static func performShowPreviousItem() async throws -> some IntentResult & ShowsSnippetView {
        guard let item = try sharedItemService.item(Item.descriptor(dateIsBefore: .now)) else {
            return .result()
        }
        return .result(
            view: incomesView(
                ListItem(of: item)
            )
        )
    }

    // MARK: - Item List

    static func performShowItemList() async throws -> some IntentResult & ShowsSnippetView {
        guard let tag = try sharedTagService.tag(Tag.descriptor(type: .year)),
              let date = tag.items?.first?.date else {
            return .result()
        }
        return .result(
            view: incomesView(
                ItemListSection(
                    title: tag.displayName,
                    descriptor: Item.descriptor(dateIsSameMonthAs: date)
                )
            )
        )
    }
}

// MARK: - Private

private extension IncomesIntent {
    static func incomesView(_ view: some View) -> some View {
        view
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