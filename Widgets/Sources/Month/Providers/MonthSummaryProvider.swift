import Foundation
import SwiftData
import WidgetKit

struct MonthSummaryProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> MonthSummaryEntry {
        let date = Date.now
        return .init(
            date: date,
            configuration: .init(),
            totalIncomeText: "$0",
            totalOutgoText: "-$0",
            deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: date)
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) -> MonthSummaryEntry {
        makeEntry(
            date: WidgetEntryFactory.targetDate(
                for: configuration.targetMonth.widgetMonthOffset,
                now: Date.now
            ),
            configuration: configuration
        )
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) -> Timeline<MonthSummaryEntry> {
        let currentDate = Date.now
        let targetDate = WidgetEntryFactory.targetDate(
            for: configuration.targetMonth.widgetMonthOffset,
            now: currentDate
        )
        let entries = WidgetEntryFactory.timelineDates(now: currentDate).map { _ in
            makeEntry(date: targetDate, configuration: configuration)
        }
        return .init(entries: entries, policy: .atEnd)
    }

    private func makeEntry(date: Date, configuration: ConfigurationAppIntent) -> MonthSummaryEntry {
        let snapshot: WidgetMonthSummarySnapshot = {
            guard let context = try? ModelContainerFactory.sharedContext() else {
                return .init(
                    totalIncomeText: "$0",
                    totalOutgoText: "-$0",
                    deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: date)
                )
            }
            return WidgetEntryFactory.monthSummarySnapshot(
                context: context,
                date: date
            ) { targetDate in
                WidgetDeepLinkBuilder.monthURL(for: targetDate)
            }
        }()
        return .init(
            date: date,
            configuration: configuration,
            totalIncomeText: snapshot.totalIncomeText,
            totalOutgoText: snapshot.totalOutgoText,
            deepLinkURL: snapshot.deepLinkURL
        )
    }
}
