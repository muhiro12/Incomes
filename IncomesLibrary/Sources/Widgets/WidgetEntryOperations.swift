import Foundation
import SwiftData

/// Creates widget timeline dates and display snapshots from shared data.
public enum WidgetEntryOperations {
    /// Returns hourly timeline entries starting from the provided date.
    public static func timelineDates(
        now: Date,
        calendar: Calendar = .current,
        entryCount: Int = 5
    ) -> [Date] {
        guard entryCount > 0 else {
            return []
        }

        return (0..<entryCount).compactMap { hourOffset in
            calendar.date(
                byAdding: .hour,
                value: hourOffset,
                to: now
            )
        }
    }

    /// Resolves the month target for a widget configuration.
    public static func targetDate(
        for monthOffset: WidgetMonthOffset,
        now: Date,
        calendar: Calendar = .current
    ) -> Date {
        calendar.date(
            byAdding: .month,
            value: monthOffset.rawValue,
            to: now
        ) ?? now
    }

    /// Creates a snapshot for the month summary widget.
    public static func monthSummarySnapshot(
        context: ModelContext,
        date: Date,
        deepLinkBuilder: (Date) -> URL
    ) -> WidgetMonthSummarySnapshot {
        let deepLinkURL = deepLinkBuilder(date)
        do {
            let totals = try ItemSummaryOperations.monthlyTotals(
                context: context,
                date: date
            )
            return .init(
                totalIncomeText: totals.totalIncome.asCurrency,
                totalOutgoText: totals.totalOutgo.asMinusCurrency,
                deepLinkURL: deepLinkURL
            )
        } catch {
            return .init(
                totalIncomeText: "$0",
                totalOutgoText: "-$0",
                deepLinkURL: deepLinkURL
            )
        }
    }

    /// Creates a snapshot for the net income widget.
    public static func netIncomeSnapshot(
        context: ModelContext,
        date: Date,
        deepLinkBuilder: (Date) -> URL
    ) -> WidgetNetIncomeSnapshot {
        let deepLinkURL = deepLinkBuilder(date)
        do {
            let totals = try ItemSummaryOperations.monthlyTotals(
                context: context,
                date: date
            )
            return .init(
                netIncomeText: totals.netIncome.asCurrency,
                isPositive: totals.netIncome > .zero || totals.netIncome == .zero,
                deepLinkURL: deepLinkURL
            )
        } catch {
            return .init(
                netIncomeText: "$0",
                isPositive: true,
                deepLinkURL: deepLinkURL
            )
        }
    }

    /// Creates a snapshot for the upcoming item widget.
    public static func upcomingSnapshot(
        context: ModelContext,
        now: Date,
        direction: WidgetUpcomingDirection,
        deepLinkBuilder: WidgetUpcomingDeepLinkBuilder
    ) -> WidgetUpcomingSnapshot {
        do {
            let item: Item?
            switch direction {
            case .next:
                item = try ItemQueryOperations.nextItem(
                    context: context,
                    date: now
                )
            case .previous:
                item = try ItemQueryOperations.previousItem(
                    context: context,
                    date: now
                )
            }

            guard let item else {
                return .init(
                    subtitleText: subtitle(for: direction),
                    titleText: "Upcoming",
                    detailText: "No items",
                    amountText: "$0",
                    isPositive: true,
                    deepLinkURL: deepLinkBuilder.homeDeepLink()
                )
            }

            let amount = item.netIncome
            let deepLinkURL: URL = {
                if let itemID = try? PersistentIdentifierCoder.encode(item.id) {
                    return deepLinkBuilder.itemDeepLink(itemID)
                }
                return deepLinkBuilder.monthDeepLink(item.localDate)
            }()

            return .init(
                subtitleText: subtitle(for: direction),
                titleText: Formatting.shortDayTitle(from: item.localDate),
                detailText: item.content,
                amountText: amount.asCurrency,
                isPositive: amount > .zero || amount == .zero,
                deepLinkURL: deepLinkURL
            )
        } catch {
            return .init(
                subtitleText: "Next",
                titleText: "Upcoming",
                detailText: "Error",
                amountText: "$0",
                isPositive: true,
                deepLinkURL: deepLinkBuilder.homeDeepLink()
            )
        }
    }

    private static func subtitle(
        for direction: WidgetUpcomingDirection
    ) -> String {
        switch direction {
        case .next:
            return "Next"
        case .previous:
            return "Previous"
        }
    }
}
