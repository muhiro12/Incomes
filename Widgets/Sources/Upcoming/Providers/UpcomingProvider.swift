import Foundation
import SwiftData
import SwiftUI
import WidgetKit

struct UpcomingProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> UpcomingEntry {
        .init(
            date: Date.now,
            subtitleText: "Next",
            titleText: "Upcoming",
            detailText: "No items",
            amountText: "$0",
            isPositive: true
        )
    }

    func snapshot(for configuration: UpcomingConfigurationAppIntent, in _: Context) -> UpcomingEntry {
        makeEntry(now: Date.now, configuration: configuration)
    }

    func timeline(for configuration: UpcomingConfigurationAppIntent, in _: Context) -> Timeline<UpcomingEntry> {
        let currentDate = Date.now
        var entries: [UpcomingEntry] = .init()
        for hourOffset in 0 ..< 5 {
            if Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) != nil {
                entries.append(makeEntry(now: currentDate, configuration: configuration))
            }
        }
        return .init(entries: entries, policy: .atEnd)
    }

    private func makeEntry(now: Date, configuration: UpcomingConfigurationAppIntent) -> UpcomingEntry {
        do {
            let context = try ModelContainerFactory.sharedContext()

            let item: Item?
            switch configuration.direction {
            case .next:
                item = try ItemService.nextItem(context: context, date: now)
            case .previous:
                item = try ItemService.previousItem(context: context, date: now)
            }

            if let item {
                let titleText: String = Formatting.shortDayTitle(from: item.localDate)
                let detailText: String = item.content
                let amount: Decimal = item.netIncome
                return .init(
                    date: now,
                    subtitleText: configuration.direction == .next ? "Next" : "Previous",
                    titleText: .init(titleText),
                    detailText: .init(detailText),
                    amountText: .init(amount.asCurrency),
                    isPositive: amount.isPlus || amount.isZero
                )
            }
            return .init(
                date: now,
                subtitleText: configuration.direction == .next ? "Next" : "Previous",
                titleText: "Upcoming",
                detailText: "No items",
                amountText: "$0",
                isPositive: true
            )
        } catch {
            return .init(
                date: now,
                subtitleText: "Next",
                titleText: "Upcoming",
                detailText: "Error",
                amountText: "$0",
                isPositive: true
            )
        }
    }
}
