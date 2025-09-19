import Foundation
import SwiftData
import WidgetKit

struct BalanceProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> BalanceEntry {
        .init(
            date: Date.now,
            configuration: .init(),
            balanceText: "$0",
            isPositive: true
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) -> BalanceEntry {
        makeEntry(date: resolveTargetDate(from: configuration, now: Date.now), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) -> Timeline<BalanceEntry> {
        let currentDate = Date.now
        let targetDate: Date = resolveTargetDate(from: configuration, now: currentDate)
        var entries: [BalanceEntry] = .init()
        for hourOffset in 0 ..< 5 {
            if Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) != nil {
                entries.append(makeEntry(date: targetDate, configuration: configuration))
            }
        }
        return .init(entries: entries, policy: .atEnd)
    }

    private func makeEntry(date: Date, configuration: ConfigurationAppIntent) -> BalanceEntry {
        do {
            let context = try ModelContainerFactory.sharedContext()
            let items: [Item] = try ItemService.items(context: context, date: date)
            let totalIncomeDecimal: Decimal = items.reduce(.zero) { partial, item in
                partial + item.income
            }
            let totalOutgoDecimal: Decimal = items.reduce(.zero) { partial, item in
                partial + item.outgo
            }
            let balance: Decimal = totalIncomeDecimal - totalOutgoDecimal
            return .init(
                date: date,
                configuration: configuration,
                balanceText: balance.asCurrency,
                isPositive: balance.isPlus || balance.isZero
            )
        } catch {
            return .init(
                date: date,
                configuration: configuration,
                balanceText: "$0",
                isPositive: true
            )
        }
    }

    private func resolveTargetDate(from configuration: ConfigurationAppIntent, now: Date) -> Date {
        switch configuration.targetMonth {
        case .previousMonth:
            return Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        case .currentMonth:
            return now
        case .nextMonth:
            return Calendar.current.date(byAdding: .month, value: 1, to: now) ?? now
        }
    }
}
