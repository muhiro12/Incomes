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

        var createdItems = [Item]()
        for yearMonth in allowedYearMonths {
            for wire in groupedIncomingItems[yearMonth].orEmpty {
                let item = try Item.create(
                    context: context,
                    date: Date(timeIntervalSince1970: wire.dateEpoch),
                    content: wire.content,
                    income: .init(wire.income),
                    outgo: .init(wire.outgo),
                    category: wire.category,
                    priority: 0,
                    repeatID: .init()
                )
                createdItems.append(item)
            }
        }

        if createdItems.isNotEmpty {
            try BalanceCalculator.calculate(
                in: context,
                for: createdItems
            )
        }

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
}

private extension WatchSyncOperations {
    static func allowedYearMonths(
        baseDate: Date,
        monthOffsets: [Int]
    ) -> Set<String> {
        Set(
            monthOffsets.compactMap { monthOffset in
                Calendar.current.date(
                    byAdding: .month,
                    value: monthOffset,
                    to: baseDate
                )?.stringValueWithoutLocale(.yyyyMM) // swiftlint:disable:this multiline_function_chains
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
