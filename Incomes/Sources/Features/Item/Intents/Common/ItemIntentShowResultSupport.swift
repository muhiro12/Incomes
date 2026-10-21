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
        defaultDate: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) -> some ProvidesDialog & ShowsSnippetView {
        let defaultOpenIntent = IncomesIntentRouteOpener.monthIntent(
            for: defaultDate, ledgerIdentifier: ledgerIdentifier
        )
        guard let item else {
            return .result(
                opensIntent: defaultOpenIntent,
                dialog: notFoundDialog
            )
        }
        return .result(
            opensIntent: IncomesIntentRouteOpener.monthIntent(
                for: item.localDate, ledgerIdentifier: item.ledgerIdentifier
            ),
            dialog: itemContentDialog(for: item)
        ) {
            IntentItemSection()
                .environment(item)
                .environment(\.ledgerIdentifier, item.ledgerIdentifier)
        }
    }

    @MainActor
    static func itemList(
        _ items: [Item],
        defaultDate: Date,
        modelContainer: ModelContainer,
        successOpenDate: Date? = nil,
        ledgerIdentifier: LedgerIdentifier = .default
    ) -> some ProvidesDialog & ShowsSnippetView {
        let defaultOpenIntent = IncomesIntentRouteOpener.monthIntent(
            for: defaultDate, ledgerIdentifier: ledgerIdentifier
        )
        guard let firstItem = items.first else {
            return .result(
                opensIntent: defaultOpenIntent,
                dialog: notFoundDialog
            )
        }
        return .result(
            opensIntent: IncomesIntentRouteOpener.monthIntent(
                for: successOpenDate ?? firstItem.localDate, ledgerIdentifier: ledgerIdentifier
            ),
            dialog: monthDialog(for: defaultDate)
        ) {
            IntentItemListSection(items)
                .modelContainer(modelContainer)
                .environment(\.ledgerIdentifier, ledgerIdentifier)
                .environment(
                    \.ledgerBalances,
                    (try? LedgerBalanceOperations.snapshot(
                        context: modelContainer.mainContext, ledgerIdentifier: ledgerIdentifier
                    ))?.balances
                    ?? [:]
                )
        }
    }

    @MainActor
    static func chartList(
        _ items: [Item],
        defaultDate: Date,
        modelContainer: ModelContainer,
        ledgerIdentifier: LedgerIdentifier = .default
    ) -> some ProvidesDialog & ShowsSnippetView {
        let openIntent = IncomesIntentRouteOpener.monthIntent(for: defaultDate, ledgerIdentifier: ledgerIdentifier)
        guard !items.isEmpty else {
            return .result(
                opensIntent: openIntent,
                dialog: notFoundDialog
            )
        }
        return .result(
            opensIntent: openIntent,
            dialog: monthDialog(for: defaultDate)
        ) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id)), ledgerIdentifier: ledgerIdentifier))
                .modelContainer(modelContainer)
                .environment(\.ledgerIdentifier, ledgerIdentifier)
                .environment(
                    \.ledgerBalances,
                    (try? LedgerBalanceOperations.snapshot(
                        context: modelContainer.mainContext, ledgerIdentifier: ledgerIdentifier
                    ))?.balances
                    ?? [:]
                )
        }
    }

    private static func itemContentDialog(for item: Item) -> IntentDialog {
        .init(stringLiteral: item.content)
    }

    private static func monthDialog(for date: Date) -> IntentDialog {
        .init(stringLiteral: date.stringValue(.yyyyMMM))
    }
}
