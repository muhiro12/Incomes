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
        try LedgerOperations.requireCompleteOwnership(context: context)
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
        // Validate the retained amounts before deleting any of the previous cache.
        let values = try items.compactMap { wire -> ItemStoredValues? in
            let date = Date(timeIntervalSince1970: wire.dateEpoch)
            guard allowedYearMonths.contains(date.stringValueWithoutLocale(.yyyyMM)) else {
                return nil
            }
            let income = try decimalAmount(wire.income)
            let outgo = try decimalAmount(wire.outgo)
            _ = try BalanceCalculator.netIncome(income: income, outgo: outgo)
            return .init(
                date: date,
                content: wire.content,
                income: income,
                outgo: outgo,
                category: wire.category,
                priority: wire.priority
            )
        }

        let allItems = try context.fetch(FetchDescriptor<Item>())
        let deleteOutcome = try ItemDeletionOperations.deleteWithOutcome(
            context: context,
            items: allItems
        )
        let createdItems = try values.map { value in
            try Item.create(context: context, values: value, repeatID: .init())
        }

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
    static func decimalAmount(_ amount: Double) throws -> Decimal {
        // The existing wire format uses Double. Its shortest round-trip spelling
        // preserves a supported phone amount without introducing binary digits.
        guard amount.isFinite,
              let decimal = Decimal(string: amount.description, locale: Locale(identifier: "en_US_POSIX")),
              AmountPrecision.isExactlyStorable(decimal) else {
            throw ItemAmountError.balanceOutOfRange
        }
        return decimal
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
            category: item.category?.name ?? "",
            priority: item.priority
        )
    }
}
