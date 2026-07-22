import Foundation
import SwiftData

/// Domain operations for updating `Item` models.
public enum ItemUpdateOperations {
    /// Returns true when updating `item` should ask which repeat scope to use.
    public static func requiresScopeSelection(
        context: ModelContext,
        item: Item
    ) throws -> Bool {
        try ItemFormSaveDecision.requiresScopeSelection(
            context: context,
            item: item
        )
    }

    /// Updates a single item with shared form input and the given mutation scope.
    public static func update(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws {
        _ = try updateWithOutcome(
            context: context,
            item: item,
            input: input,
            scope: scope
        )
    }

    /// Updates item(s) and returns mutation metadata.
    public static func updateWithOutcome(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> MutationOutcome {
        try input.validate()
        let values = ItemStoredValues(formInput: input)

        let affectedItems = try ItemMutationSupport.itemsForMutationScope(
            context: context,
            item: item,
            scope: scope
        )
        let snapshot = ItemUpdateSnapshot(items: affectedItems)

        try updateItems(
            context: context,
            item: item,
            values: values,
            scope: scope
        )

        TagMutationOperations.deleteUnused(tags: snapshot.tagsToCleanup)
        return updateOutcome(
            snapshot: snapshot,
            affectedItems: affectedItems,
            inputDate: values.date
        )
    }

    /// Updates a set of repeating items specified by `descriptor` using the delta
    /// between the original item's date and the new value date, then recalculates balances.
    public static func updateRepeatingItems(
        context: ModelContext,
        item: Item,
        values: ItemStoredValues,
        descriptor: FetchDescriptor<Item>
    ) throws {
        let dateShift = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: item.localDate,
            to: values.date
        )
        let repeatID = UUID()
        let items = try context.fetch(descriptor)
        let recalcDate = try updateRepeatingItems(
            items: items,
            dateShift: dateShift,
            values: values,
            repeatID: repeatID
        )
        try BalanceCalculator.calculate(
            in: context,
            after: recalcDate ?? values.date
        )
    }
}

private extension ItemUpdateOperations {
    struct ItemUpdateSnapshot {
        let tagsToCleanup: [Tag]
        let beforeDates: [Date]
        let updatedIDs: Set<PersistentIdentifier>

        init(items: [Item]) {
            self.tagsToCleanup = ItemMutationSupport.cleanupCandidateTags(from: items)
            self.beforeDates = items.map(\.localDate)
            self.updatedIDs = Set(items.map(\.persistentModelID))
        }
    }

    static func updateItems(
        context: ModelContext,
        item: Item,
        values: ItemStoredValues,
        scope: ItemMutationScope
    ) throws {
        switch scope {
        case .thisItem:
            try updateSingleItem(context: context, item: item, values: values)
        case .futureItems:
            try updateFutureItems(context: context, item: item, values: values)
        case .allItems:
            try updateAllItems(context: context, item: item, values: values)
        }
    }

    static func updateOutcome(
        snapshot: ItemUpdateSnapshot,
        affectedItems: [Item],
        inputDate: Date
    ) -> MutationOutcome {
        let afterDates = affectedItems.map(\.localDate)
        let candidateDates = snapshot.beforeDates + afterDates + [inputDate]
        return .init(
            changedIDs: .init(
                created: [],
                updated: snapshot.updatedIDs,
                deleted: []
            ),
            affectedDateRange: ItemMutationSupport.dateRange(from: candidateDates),
            followUpHints: ItemMutationSupport.followUpHints
        )
    }

    static func updateSingleItem(
        context: ModelContext,
        item: Item,
        values: ItemStoredValues
    ) throws {
        let originalDate = item.localDate
        try item.modify(
            values: values,
            repeatID: .init()
        )
        let recalcDate = min(originalDate, item.localDate)
        try BalanceCalculator.calculate(in: context, after: recalcDate)
    }

    static func updateAllItems(
        context: ModelContext,
        item: Item,
        values: ItemStoredValues
    ) throws {
        try updateRepeatingItems(
            context: context,
            item: item,
            values: values,
            descriptor: .items(.repeatIDIs(item.repeatID))
        )
    }

    static func updateFutureItems(
        context: ModelContext,
        item: Item,
        values: ItemStoredValues
    ) throws {
        try updateRepeatingItems(
            context: context,
            item: item,
            values: values,
            descriptor: .items(
                .repeatIDAndDateIsAfter(
                    repeatID: item.repeatID,
                    date: item.localDate
                )
            )
        )
    }

    static func updateRepeatingItems(
        items: [Item],
        dateShift: DateComponents,
        values: ItemStoredValues,
        repeatID: UUID
    ) throws -> Date? {
        var recalcDate: Date?
        try items.forEach { item in
            let originalDate = item.localDate
            guard let newDate = Calendar.current.date(byAdding: dateShift, to: originalDate) else {
                assertionFailure()
                return
            }
            recalcDate = earliestDate(
                among: recalcDate,
                originalDate,
                newDate
            )
            try item.modify(
                values: values.replacing(date: newDate),
                repeatID: repeatID
            )
        }
        return recalcDate
    }

    static func earliestDate(_ firstDate: Date?, _ secondDate: Date) -> Date {
        if let firstDate {
            min(firstDate, secondDate)
        } else {
            secondDate
        }
    }

    static func earliestDate(
        among currentDate: Date?,
        _ candidateDates: Date...
    ) -> Date? {
        candidateDates.reduce(currentDate) { earliest, candidate in
            earliestDate(earliest, candidate)
        }
    }
}
