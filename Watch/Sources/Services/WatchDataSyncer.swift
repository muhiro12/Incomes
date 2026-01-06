//
//  WatchDataSyncer.swift
//  Watch
//
//  Created by Codex on 2025/09/21.
//

import Foundation
import SwiftData

enum WatchDataSyncer {
    static func syncRecentMonths(context: ModelContext) async {
        let baseDate = Date()
        let months: [Int] = [-1, 0, 1]
        let allowedYearMonths: Set<String> = Set(months.compactMap { offset in
            Calendar.current.date(
                byAdding: .month,
                value: offset,
                to: baseDate
            )?.stringValueWithoutLocale(.yyyyMM)
        })

        let items = await PhoneSyncClient.shared.requestRecentItems()
        // Group incoming by yearMonth for easier replacement
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.dateFormat = "yyyyMM"

        var grouped: [String: [ItemWire]] = [:]
        for wire in items {
            let key = formatter.string(from: Date(timeIntervalSince1970: wire.dateEpoch))
            grouped[key, default: []].append(wire)
        }

        // Delete items not in allowed months
        let all: [Item] = (try? context.fetch(FetchDescriptor<Item>())) ?? []
        for item in all where !allowedYearMonths.contains(item.localDate.stringValueWithoutLocale(.yyyyMM)) {
            try? ItemService.delete(context: context, item: item)
        }

        // Replace items for each allowed month with incoming snapshot
        for ym in allowedYearMonths {
            // Delete existing items for that month
            for item in all where item.localDate.stringValueWithoutLocale(.yyyyMM) == ym {
                try? ItemService.delete(context: context, item: item)
            }

            // Create incoming items
            for wire in grouped[ym].orEmpty {
                _ = try? Item.create(
                    context: context,
                    date: Date(timeIntervalSince1970: wire.dateEpoch),
                    content: wire.content,
                    income: .init(wire.income),
                    outgo: .init(wire.outgo),
                    category: wire.category,
                    repeatID: .init()
                )
            }
        }

        // Recalculate balances after sync
        try? BalanceCalculator.calculate(in: context, after: Calendar.utc.startOfYear(for: baseDate))
    }
}
