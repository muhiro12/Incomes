import Foundation
import SwiftData
import WidgetKit

struct NetIncomeProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> NetIncomeEntry {
        let date = Date.now
        return .init(
            date: date,
            targetDate: date,
            configuration: .init(),
            netIncomeText: "$0",
            isPositive: true,
            deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: date)
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) -> NetIncomeEntry {
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

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) -> Timeline<NetIncomeEntry> {
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
    ) -> NetIncomeEntry {
        let snapshot: WidgetNetIncomeSnapshot = {
            guard let context = try? ModelContainerFactory.sharedContext() else {
                return .init(
                    netIncomeText: "$0",
                    isPositive: true,
                    deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: targetDate)
                )
            }
            return WidgetEntryOperations.netIncomeSnapshot(
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
            netIncomeText: snapshot.netIncomeText,
            isPositive: snapshot.isPositive,
            deepLinkURL: snapshot.deepLinkURL
        )
    }
}
