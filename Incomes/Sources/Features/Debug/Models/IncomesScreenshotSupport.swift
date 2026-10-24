#if DEBUG
import Foundation
import SwiftData
import SwiftUI

/// Isolates explicitly requested Store captures from saved records and services.
enum IncomesScreenshotSupport {
    private static let chartDefaultVerticalAnchor: CGFloat = 0.01
    private static let chartLayoutDelayMilliseconds = 500
    private static let chartLayoutDelay: Duration = .milliseconds(chartLayoutDelayMilliseconds)
    private static let cardOutgoBaseUSD: Decimal = 900

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("--incomes-screenshots")
    }

    static var showsItemInformation: Bool {
        isEnabled && ProcessInfo.processInfo.arguments.contains("--incomes-screenshots-info")
    }

    private static var chartScrollAnchor: UnitPoint {
        var verticalAnchor = chartDefaultVerticalAnchor
        if isEnabled,
           let value = ProcessInfo.processInfo.environment["INCOMES_SCREENSHOT_CHART_ANCHOR"],
           let requestedAnchor = Double(value),
           (UnitPoint.top.y...UnitPoint.bottom.y).contains(CGFloat(requestedAnchor)) {
            verticalAnchor = CGFloat(requestedAnchor)
        }
        return .init(x: UnitPoint.top.x, y: verticalAnchor)
    }

    @MainActor
    static func positionCharts(using scrollProxy: ScrollViewProxy) async {
        scrollProxy.scrollTo("incomes-screenshot-balance-section", anchor: chartScrollAnchor)
        do {
            try await Task.sleep(for: chartLayoutDelay)
        } catch {
            return
        }
        // Lazy List rows have their final heights only after the first scroll.
        scrollProxy.scrollTo("incomes-screenshot-balance-section", anchor: chartScrollAnchor)
    }

    @MainActor
    static func presentItemInformationIfRequested(
        context: ModelContext,
        router: MainNavigationRouter
    ) {
        guard showsItemInformation else {
            return
        }
        do {
            let items = try ItemQueryOperations.items(
                context: context,
                date: .now,
                ledgerIdentifier: router.ledgerIdentifier
            )
            let expectedOutgo = LocaleAmountConverter.localizedAmount(baseUSD: cardOutgoBaseUSD)
            guard let item = items.first(where: { item in
                item.outgo == expectedOutgo
            }) else {
                preconditionFailure("Missing sample card payment for screenshots")
            }
            let itemID = try PersistentIdentifierCoder.encode(item.persistentModelID)
            try router.navigate(to: .item(itemID), context: context)
        } catch {
            preconditionFailure("Failed to present screenshot item information: \(error)")
        }
    }
}

#endif
