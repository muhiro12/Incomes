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
            isPositive: true,
            deepLinkURL: WidgetDeepLinkBuilder.homeURL()
        )
    }

    func snapshot(for configuration: UpcomingConfigurationAppIntent, in _: Context) -> UpcomingEntry {
        makeEntry(now: Date.now, configuration: configuration)
    }

    func timeline(for configuration: UpcomingConfigurationAppIntent, in _: Context) -> Timeline<UpcomingEntry> {
        let currentDate = Date.now
        let entries = WidgetEntryOperations.timelineDates(now: currentDate).map { _ in
            makeEntry(now: currentDate, configuration: configuration)
        }
        return .init(entries: entries, policy: .atEnd)
    }

    private func makeEntry(now: Date, configuration: UpcomingConfigurationAppIntent) -> UpcomingEntry {
        let snapshot: WidgetUpcomingSnapshot = {
            guard let context = try? ModelContainerFactory.sharedContext() else {
                return .init(
                    subtitleText: "Next",
                    titleText: "Upcoming",
                    detailText: "Error",
                    amountText: "$0",
                    isPositive: true,
                    deepLinkURL: WidgetDeepLinkBuilder.homeURL()
                )
            }
            return WidgetEntryOperations.upcomingSnapshot(
                context: context,
                now: now,
                direction: configuration.direction.widgetUpcomingDirection,
                deepLinkBuilder: .init(
                    homeDeepLink: {
                        WidgetDeepLinkBuilder.homeURL()
                    },
                    monthDeepLink: { date in
                        WidgetDeepLinkBuilder.monthURL(for: date)
                    },
                    itemDeepLink: { itemID in
                        WidgetDeepLinkBuilder.itemURL(for: itemID)
                    }
                )
            )
        }()
        return .init(
            date: now,
            subtitleText: .init(snapshot.subtitleText),
            titleText: .init(snapshot.titleText),
            detailText: .init(snapshot.detailText),
            amountText: .init(snapshot.amountText),
            isPositive: snapshot.isPositive,
            deepLinkURL: snapshot.deepLinkURL
        )
    }
}
