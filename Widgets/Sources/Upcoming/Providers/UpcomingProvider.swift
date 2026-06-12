import Foundation
import SwiftData
import SwiftUI
import WidgetKit

struct UpcomingProvider: AppIntentTimelineProvider {
    private enum EntryTextRole {
        case subtitle
        case title
        case detail
    }

    func placeholder(in _: Context) -> UpcomingEntry {
        .init(
            date: Date.now,
            subtitleText: Text("Next"),
            titleText: Text("Upcoming"),
            detailText: Text("No items"),
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
        let entries = WidgetEntryOperations.timelineDates(now: currentDate).map { date in
            makeEntry(now: date, configuration: configuration)
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
            subtitleText: entryText(snapshot.subtitleText, role: .subtitle),
            titleText: entryText(snapshot.titleText, role: .title),
            detailText: entryText(snapshot.detailText, role: .detail),
            amountText: snapshot.amountText,
            isPositive: snapshot.isPositive,
            deepLinkURL: snapshot.deepLinkURL
        )
    }

    private func entryText(_ value: String, role: EntryTextRole) -> Text {
        switch role {
        case .subtitle:
            subtitleText(value)
        case .title:
            titleText(value)
        case .detail:
            detailText(value)
        }
    }

    private func subtitleText(_ value: String) -> Text {
        switch value {
        case "Next":
            Text("Next")
        case "Previous":
            Text("Previous")
        default:
            Text(verbatim: value)
        }
    }

    private func titleText(_ value: String) -> Text {
        if value == "Upcoming" {
            return Text("Upcoming")
        }
        return Text(verbatim: value)
    }

    private func detailText(_ value: String) -> Text {
        switch value {
        case "Error":
            Text("Error")
        case "No items":
            Text("No items")
        default:
            Text(verbatim: value)
        }
    }
}
