#if DEBUG
import Foundation
import SwiftData
import SwiftUI

/// Isolates explicitly requested Store captures from saved records and services.
enum IncomesScreenshotSupport {
    static let chartVerticalAnchor = 0.08
    static let chartScrollAnchor: UnitPoint = .init(x: UnitPoint.top.x, y: chartVerticalAnchor)
    private static let cardOutgoBaseUSD: Decimal = 900

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("--incomes-screenshots")
    }

    static var showsItemInformation: Bool {
        isEnabled && ProcessInfo.processInfo.arguments.contains("--incomes-screenshots-info")
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
