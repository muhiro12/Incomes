import Foundation
import SwiftData

enum ItemMutationSupport {
    static let followUpHints: Set<MutationOutcome.FollowUpHint> = [
        .refreshNotificationSchedule,
        .reloadWidgets,
        .refreshWatchSnapshot
    ]

    static func performAndSave<Value>(
        context: ModelContext,
        pendingChangesError: any Error = ItemMutationError.pendingChanges,
        operation: () throws -> Value
    ) throws -> Value {
        guard !context.hasChanges else {
            throw pendingChangesError
        }
        guard context.container.configurations.allSatisfy(\.allowsSave) else {
            throw CocoaError(.fileWriteNoPermission)
        }
        return try MutationPersistenceSupport.commit(context: context, operation: operation)
    }

    static func performAndSaveCreatedItems<Value>(
        context: ModelContext,
        pendingChangesError: any Error = ItemMutationError.pendingChanges,
        operation: () throws -> MutationResult<Value>
    ) throws -> MutationResult<Value> {
        let (mutation, createdItems) = try performAndSave(
            context: context,
            pendingChangesError: pendingChangesError
        ) {
            let mutation = try operation()
            let createdItems = context.insertedModelsArray.compactMap { model in
                model as? Item
            }
            return (mutation, createdItems)
        }
        return .init(
            value: mutation.value,
            outcome: .init(
                changedIDs: .init(
                    created: Set(createdItems.map(\.persistentModelID)),
                    updated: mutation.outcome.changedIDs.updated,
                    deleted: mutation.outcome.changedIDs.deleted
                ),
                affectedDateRange: mutation.outcome.affectedDateRange,
                followUpHints: mutation.outcome.followUpHints
            )
        )
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
                case .debug, .ledger, .defaultLedger, .none:
                    return false
                }
            }
        }
    }
}
