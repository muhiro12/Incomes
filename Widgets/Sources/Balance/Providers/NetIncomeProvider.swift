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
        makeEntry(
            date: WidgetEntryOperations.targetDate(
                for: configuration.targetMonth.widgetMonthOffset,
                now: Date.now
            ),
            configuration: configuration
        )
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) -> Timeline<NetIncomeEntry> {
        let currentDate = Date.now
        let targetDate = WidgetEntryOperations.targetDate(
            for: configuration.targetMonth.widgetMonthOffset,
            now: currentDate
        )
        let entries = WidgetEntryOperations.timelineDates(now: currentDate).map { _ in
            makeEntry(date: targetDate, configuration: configuration)
        }
        return .init(entries: entries, policy: .atEnd)
    }

    private func makeEntry(date: Date, configuration: ConfigurationAppIntent) -> NetIncomeEntry {
        let snapshot: WidgetNetIncomeSnapshot = {
            guard let context = try? ModelContainerFactory.sharedContext() else {
                return .init(
                    netIncomeText: "$0",
                    isPositive: true,
                    deepLinkURL: WidgetDeepLinkBuilder.monthURL(for: date)
                )
            }
            return WidgetEntryOperations.netIncomeSnapshot(
                context: context,
                date: date
            ) { targetDate in
                WidgetDeepLinkBuilder.monthURL(for: targetDate)
            }
        }()
        return .init(
            date: date,
            configuration: configuration,
            netIncomeText: snapshot.netIncomeText,
            isPositive: snapshot.isPositive,
            deepLinkURL: snapshot.deepLinkURL
        )
    }
}
