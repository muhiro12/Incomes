import Foundation
import SwiftData
import WidgetKit

struct MonthSummaryProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> MonthSummaryEntry {
        let date = Date.now
        return .init(
            date: date,
            targetDate: date,
            configuration: .init(),
            totalIncomeText: "$0",
            totalOutgoText: "-$0",
            deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: date)
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) -> MonthSummaryEntry {
        let date = Date.now
        return makeEntry(
            date: date,
            targetDate: WidgetEntryOperations.targetDate(
                for: configuration.targetMonth.widgetMonthOffset,
                now: date
            ),
            configuration: configuration
        )
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) -> Timeline<MonthSummaryEntry> {
        let currentDate = Date.now
        let entries = WidgetEntryOperations.timelineDates(now: currentDate).map { date in
            makeEntry(
                date: date,
                targetDate: WidgetEntryOperations.targetDate(
                    for: configuration.targetMonth.widgetMonthOffset,
                    now: date
                ),
                configuration: configuration
            )
        }
        return .init(entries: entries, policy: .atEnd)
    }

    private func makeEntry(
        date: Date,
        targetDate: Date,
        configuration: ConfigurationAppIntent
    ) -> MonthSummaryEntry {
        let snapshot: WidgetMonthSummarySnapshot = {
            guard let context = try? ModelContainerFactory.sharedContext() else {
                return .init(
                    totalIncomeText: "$0",
                    totalOutgoText: "-$0",
                    deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: targetDate)
                )
            }
            return WidgetEntryOperations.monthSummarySnapshot(
                context: context,
                date: targetDate
            ) { targetDate in
                WidgetDeepLinkBuilder.monthURL(for: targetDate)
            }
        }()
        return .init(
            date: date,
            targetDate: targetDate,
            configuration: configuration,
            totalIncomeText: snapshot.totalIncomeText,
            totalOutgoText: snapshot.totalOutgoText,
            deepLinkURL: snapshot.deepLinkURL
        )
    }
}
