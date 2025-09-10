import Foundation
import SwiftData
import WidgetKit

struct MonthSummaryProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> MonthSummaryEntry {
        .init(date: Date.now, configuration: .init(), itemCount: 0, monthBalance: "-")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) -> MonthSummaryEntry {
        makeEntry(date: resolveTargetDate(from: configuration, now: Date.now), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) -> Timeline<MonthSummaryEntry> {
        let currentDate = Date.now
        let targetDate: Date = resolveTargetDate(from: configuration, now: currentDate)
        var entries: [MonthSummaryEntry] = .init()
        for hourOffset in 0 ..< 5 {
            if let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) {
                // Keep updating the same target month while advancing the timeline time.
                entries.append(makeEntry(date: targetDate, configuration: configuration))
            }
        }
        return .init(entries: entries, policy: .atEnd)
    }

    private func makeEntry(date: Date, configuration: ConfigurationAppIntent) -> MonthSummaryEntry {
        do {
            let container: ModelContainer = try .init(for: Item.self, Tag.self)
            let context: ModelContext = .init(container)
            let items: [Item] = try ItemService.items(context: context, date: date)
            let itemCount: Int = items.count
            let monthBalanceDecimal: Decimal = items.reduce(.zero) { $0 + $1.profit }
            let monthBalance: String = monthBalanceDecimal.asCurrency
            return .init(date: date, configuration: configuration, itemCount: itemCount, monthBalance: monthBalance)
        } catch {
            return .init(date: date, configuration: configuration, itemCount: 0, monthBalance: "-")
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
