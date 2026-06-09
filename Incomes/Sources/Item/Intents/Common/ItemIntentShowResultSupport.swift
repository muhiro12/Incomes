import AppIntents
import Foundation
import SwiftData

enum ItemIntentShowResultSupport {
    private static var notFoundDialog: IntentDialog {
        .init(.init("Not Found", table: "AppIntents"))
    }

    @MainActor
    static func singleItem(
        _ item: Item?,
        defaultDate: Date
    ) -> some ProvidesDialog & ShowsSnippetView {
        let defaultOpenIntent = IncomesIntentRouteOpener.monthIntent(for: defaultDate)
        guard let item else {
            return .result(
                opensIntent: defaultOpenIntent,
                dialog: notFoundDialog
            )
        }
        return .result(
            opensIntent: IncomesIntentRouteOpener.monthIntent(for: item.localDate),
            dialog: itemContentDialog(for: item)
        ) {
            IntentItemSection()
                .environment(item)
        }
    }

    @MainActor
    static func relativeSingleItem(
        modelContainer: ModelContainer,
        date: Date,
        direction: ItemRelativeQueryCoordinator.Direction
    ) throws -> some ProvidesDialog & ShowsSnippetView {
        let item = try ItemRelativeQueryCoordinator.item(
            context: modelContainer.mainContext,
            date: date,
            direction: direction
        )
        return singleItem(
            item,
            defaultDate: date
        )
    }

    @MainActor
    static func itemList(
        _ items: [Item],
        defaultDate: Date,
        modelContainer: ModelContainer,
        successOpenDate: Date? = nil
    ) -> some ProvidesDialog & ShowsSnippetView {
        let defaultOpenIntent = IncomesIntentRouteOpener.monthIntent(for: defaultDate)
        guard let firstItem = items.first else {
            return .result(
                opensIntent: defaultOpenIntent,
                dialog: notFoundDialog
            )
        }
        return .result(
            opensIntent: IncomesIntentRouteOpener.monthIntent(for: successOpenDate ?? firstItem.localDate),
            dialog: monthDialog(for: defaultDate)
        ) {
            IntentItemListSection(items)
                .modelContainer(modelContainer)
        }
    }

    @MainActor
    static func relativeItemList(
        modelContainer: ModelContainer,
        date: Date,
        direction: ItemRelativeQueryCoordinator.Direction
    ) throws -> some ProvidesDialog & ShowsSnippetView {
        let items = try ItemRelativeQueryCoordinator.items(
            context: modelContainer.mainContext,
            date: date,
            direction: direction
        )
        return itemList(
            items,
            defaultDate: date,
            modelContainer: modelContainer
        )
    }

    @MainActor
    static func datedItemList(
        modelContainer: ModelContainer,
        date: Date
    ) throws -> some ProvidesDialog & ShowsSnippetView {
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: date
        )
        return itemList(
            items,
            defaultDate: date,
            modelContainer: modelContainer,
            successOpenDate: date
        )
    }

    @MainActor
    static func chartList(
        _ items: [Item],
        defaultDate: Date,
        modelContainer: ModelContainer
    ) -> some ProvidesDialog & ShowsSnippetView {
        let openIntent = IncomesIntentRouteOpener.monthIntent(for: defaultDate)
        guard items.isNotEmpty else {
            return .result(
                opensIntent: openIntent,
                dialog: notFoundDialog
            )
        }
        return .result(
            opensIntent: openIntent,
            dialog: monthDialog(for: defaultDate)
        ) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }

    @MainActor
    static func datedChartList(
        modelContainer: ModelContainer,
        date: Date
    ) throws -> some ProvidesDialog & ShowsSnippetView {
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: date
        )
        return chartList(
            items,
            defaultDate: date,
            modelContainer: modelContainer
        )
    }

    private static func itemContentDialog(for item: Item) -> IntentDialog {
        .init(stringLiteral: item.content)
    }

    private static func monthDialog(for date: Date) -> IntentDialog {
        .init(stringLiteral: date.stringValue(.yyyyMMM))
    }
}
