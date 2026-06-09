import AppIntents
import Foundation
import SwiftData

enum ItemIntentShowResultSupport {
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
    static func itemList(
        _ items: [Item],
        defaultDate: Date,
        successOpenDate: Date? = nil,
        modelContainer: ModelContainer
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

    private static var notFoundDialog: IntentDialog {
        .init(.init("Not Found", table: "AppIntents"))
    }

    private static func itemContentDialog(for item: Item) -> IntentDialog {
        .init(stringLiteral: item.content)
    }

    private static func monthDialog(for date: Date) -> IntentDialog {
        .init(stringLiteral: date.stringValue(.yyyyMMM))
    }
}
