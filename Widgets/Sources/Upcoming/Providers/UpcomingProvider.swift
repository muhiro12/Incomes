import Foundation
import SwiftData
import WidgetKit

struct UpcomingProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> UpcomingEntry {
        .init(
            date: Date.now,
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
            let modelContainer = try ModelContainer(
                for: Item.self,
                configurations: .init(
                    url: Database.url
                )
            )
            let context = ModelContext(modelContainer)

            let item: Item?
            switch configuration.direction {
            case .next:
                item = try ItemService.nextItem(context: context, date: now)
            case .previous:
                item = try ItemService.previousItem(context: context, date: now)
            }

            if let item {
                let dateFormatter: DateFormatter = .init()
                dateFormatter.locale = .current
                dateFormatter.dateFormat = "MMM d (EEE)"
                let titleText: String = dateFormatter.string(from: item.localDate)
                let detailText: String = item.content
                let amount: Decimal = item.profit
                return .init(
                    date: now,
                    titleText: titleText,
                    detailText: detailText,
                    amountText: amount.asCurrency,
                    isPositive: amount.isPlus || amount.isZero
                )
            }
            return .init(
                date: now,
                titleText: "Upcoming",
                detailText: "No items",
                amountText: "$0",
                isPositive: true
            )
        } catch {
            return .init(
                date: now,
                titleText: "Upcoming",
                detailText: "Error",
                amountText: "$0",
                isPositive: true
            )
        }
    }
}
