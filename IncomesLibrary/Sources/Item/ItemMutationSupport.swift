import Foundation
import SwiftData

enum ItemMutationSupport {
    static let followUpHints: Set<MutationOutcome.FollowUpHint> = [
        .refreshNotificationSchedule,
        .reloadWidgets,
        .refreshWatchSnapshot
    ]

    static func performAndSave(
        context: ModelContext,
        operation: () throws -> MutationOutcome
    ) throws -> MutationOutcome {
        guard !context.hasChanges else {
            throw ItemMutationError.pendingChanges
        }
        guard context.container.configurations.allSatisfy(\.allowsSave) else {
            throw CocoaError(.fileWriteNoPermission)
        }
        let autosaveEnabled = context.autosaveEnabled
        context.autosaveEnabled = false
        defer {
            context.autosaveEnabled = autosaveEnabled
        }
        do {
            let outcome = try operation()
            try context.save()
            return outcome
        } catch {
            context.rollback()
            throw error
        }
    }

    static func dateRange(from dates: [Date]) -> ClosedRange<Date>? {
        guard let minDate = dates.min(),
              let maxDate = dates.max() else {
            return nil
        }
        return minDate...maxDate
    }

    static func itemsForMutationScope(
        context: ModelContext,
        item: Item,
        scope: ItemMutationScope
    ) throws -> [Item] {
        switch scope {
        case .thisItem:
            return [item]
        case .futureItems:
            return try context.fetch(
                .items(
                    .repeatIDAndDateIsAfter(
                        repeatID: item.repeatID,
                        date: item.localDate
                    ),
                    ledgerIdentifier: item.ledgerIdentifier
                )
            )
        case .allItems:
            return try context.fetch(
                .items(.repeatIDIs(item.repeatID), ledgerIdentifier: item.ledgerIdentifier)
            )
        }
    }

    static func cleanupCandidateTags(from items: [Item]) -> [Tag] {
        items.flatMap { item in
            (item.tags ?? []).filter { tag in
                switch tag.type {
                case .year, .yearMonth, .content, .category:
                    return true
                case .debug, .ledger, .none:
                    return false
                }
            }
        }
    }
}
