import Foundation
import SwiftData
import WidgetKit

struct MonthSummaryProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> MonthSummaryEntry {
        .init(
            date: Date.now,
            configuration: .init(),
            totalIncomeText: "$0",
            totalOutgoText: "-$0"
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) -> MonthSummaryEntry {
        makeEntry(date: resolveTargetDate(from: configuration, now: Date.now), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) -> Timeline<MonthSummaryEntry> {
        let currentDate = Date.now
        let targetDate: Date = resolveTargetDate(from: configuration, now: currentDate)
        var entries: [MonthSummaryEntry] = .init()
        for hourOffset in 0 ..< 5 {
            if Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) != nil {
                entries.append(makeEntry(date: targetDate, configuration: configuration))
            }
        }
        return .init(entries: entries, policy: .atEnd)
    }

    private func makeEntry(date: Date, configuration: ConfigurationAppIntent) -> MonthSummaryEntry {
        do {
            let context = try ModelContainerFactory.sharedContext()
            let items: [Item] = try ItemService.items(context: context, date: date)
            let totalIncomeDecimal: Decimal = items.reduce(.zero) { partial, item in
                partial + item.income
            }
            let totalOutgoDecimal: Decimal = items.reduce(.zero) { partial, item in
                partial + item.outgo
            }
            let totalIncomeText: String = totalIncomeDecimal.asCurrency
            let totalOutgoText: String = totalOutgoDecimal.asMinusCurrency
            return .init(
                date: date,
                configuration: configuration,
                totalIncomeText: totalIncomeText,
                totalOutgoText: totalOutgoText
            )
        } catch {
            return .init(
                date: date,
                configuration: configuration,
                totalIncomeText: "$0",
                totalOutgoText: "-$0"
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
