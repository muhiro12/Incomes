import Foundation
import SwiftData
import WidgetKit

struct NetIncomeProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> NetIncomeEntry {
        let date = Date.now
        return .init(
            date: date,
            configuration: .init(),
            netIncomeText: "$0",
            isPositive: true,
            deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: date)
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) -> NetIncomeEntry {
        makeEntry(date: resolveTargetDate(from: configuration, now: Date.now), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) -> Timeline<NetIncomeEntry> {
        let currentDate = Date.now
        let targetDate: Date = resolveTargetDate(from: configuration, now: currentDate)
        var entries: [NetIncomeEntry] = .init()
        for hourOffset in 0 ..< 5 where Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) != nil {
            entries.append(makeEntry(date: targetDate, configuration: configuration))
        }
        return .init(entries: entries, policy: .atEnd)
    }

    private func makeEntry(date: Date, configuration: ConfigurationAppIntent) -> NetIncomeEntry {
        let deepLinkURL = WidgetDeepLinkBuilder.monthURL(for: date)
        do {
            let context = try ModelContainerFactory.sharedContext()
            let totals = try SummaryCalculator.monthlyTotals(context: context, date: date)
            return .init(
                date: date,
                configuration: configuration,
                netIncomeText: totals.netIncome.asCurrency,
                isPositive: totals.netIncome.isPlus || totals.netIncome.isZero,
                deepLinkURL: deepLinkURL
            )
        } catch {
            return .init(
                date: date,
                configuration: configuration,
                netIncomeText: "$0",
                isPositive: true,
                deepLinkURL: deepLinkURL
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
