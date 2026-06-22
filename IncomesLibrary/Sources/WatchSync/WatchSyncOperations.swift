import Foundation
import SwiftData

/// Synchronizes watch snapshots into the shared item store.
public enum WatchSyncOperations {
    static let recentItemsPerMonthLimit = 50
    static let recentItemsResponseLimit = 120

    /// Builds recent item wire snapshots for the requested month window.
    public static func recentItemWires(
        context: ModelContext,
        baseDate: Date,
        monthOffsets: [Int] = ItemsRequest.recentMonthOffsets
    ) throws -> [ItemWire] {
        var wires = [ItemWire]()
        for monthOffset in monthOffsets {
            guard let monthDate = Calendar.current.date(
                byAdding: .month,
                value: monthOffset,
                to: baseDate
            ) else {
                continue
            }
            let items = try ItemQueryOperations.items(
                context: context,
                date: monthDate
            )
            for item in items.prefix(recentItemsPerMonthLimit) {
                wires.append(.init(item: item))
            }
        }
        return Array(wires.prefix(recentItemsResponseLimit))
    }

    /// Applies watch snapshot items for the requested month window.
    public static func applySnapshot(
        context: ModelContext,
        items: [ItemWire],
        baseDate: Date = .now,
        monthOffsets: [Int] = ItemsRequest.recentMonthOffsets
    ) throws -> MutationOutcome {
        let allowedYearMonths = allowedYearMonths(
            baseDate: baseDate,
            monthOffsets: monthOffsets
        )
        let groupedIncomingItems = Dictionary(grouping: items) { wire in
            Date(timeIntervalSince1970: wire.dateEpoch)
                .stringValueWithoutLocale(.yyyyMM)
        }

        let allItems = try context.fetch(FetchDescriptor<Item>())
        let deleteOutcome = try ItemDeletionOperations.deleteWithOutcome(
            context: context,
            items: allItems
        )
        let createdItems = try createItems(
            context: context,
            groupedIncomingItems: groupedIncomingItems,
            allowedYearMonths: allowedYearMonths
        )

        if !createdItems.isEmpty {
            try BalanceCalculator.calculate(
                in: context,
                for: createdItems
            )
        }

        return snapshotOutcome(
            createdItems: createdItems,
            deleteOutcome: deleteOutcome
        )
    }
}

private extension WatchSyncOperations {
    static func createItems(
        context: ModelContext,
        groupedIncomingItems: [String: [ItemWire]],
        allowedYearMonths: Set<String>
    ) throws -> [Item] {
        try allowedYearMonths.flatMap { yearMonth in
            try (groupedIncomingItems[yearMonth] ?? []).map { wire in
                try createItem(context: context, wire: wire)
            }
        }
    }

    static func createItem(context: ModelContext, wire: ItemWire) throws -> Item {
        try Item.create(
            context: context,
            values: .init(
                date: Date(timeIntervalSince1970: wire.dateEpoch),
                content: wire.content,
                income: .init(wire.income),
                outgo: .init(wire.outgo),
                category: wire.category,
                priority: 0
            ),
            repeatID: .init()
        )
    }

    static func snapshotOutcome(
        createdItems: [Item],
        deleteOutcome: MutationOutcome
    ) -> MutationOutcome {
        let createdIDs = Set(createdItems.map(\.persistentModelID))
        let createdDates = createdItems.map(\.localDate)
        let affectedDateRange = dateRange(
            dates: createdDates + (deleteOutcome.affectedDateRange.map { [$0.lowerBound, $0.upperBound] } ?? [])
        )

        return .init(
            changedIDs: .init(
                created: createdIDs,
                updated: [],
                deleted: deleteOutcome.changedIDs.deleted
            ),
            affectedDateRange: affectedDateRange,
            followUpHints: [.reloadWidgets, .refreshWatchSnapshot]
        )
    }

    static func allowedYearMonths(
        baseDate: Date,
        monthOffsets: [Int]
    ) -> Set<String> {
        Set(
            monthOffsets.compactMap { monthOffset in
                let date = Calendar.current.date(
                    byAdding: .month,
                    value: monthOffset,
                    to: baseDate
                )
                return date?.stringValueWithoutLocale(.yyyyMM)
            }
        )
    }

    static func dateRange(dates: [Date]) -> ClosedRange<Date>? {
        guard let minDate = dates.min(),
              let maxDate = dates.max() else {
            return nil
        }
        return minDate...maxDate
    }
}

private extension ItemWire {
    init(item: Item) {
        self.init(
            dateEpoch: item.localDate.timeIntervalSince1970,
            content: item.content,
            income: Double(item.income.description) ?? .zero,
            outgo: Double(item.outgo.description) ?? .zero,
            category: item.category?.name ?? ""
        )
    }
}
