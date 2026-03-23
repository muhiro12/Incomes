import Foundation
import SwiftData

/// Creates widget timeline dates and display snapshots from shared data.
public enum WidgetEntryFactory {
    /// Returns hourly timeline entries starting from the provided date.
    public static func timelineDates(
        now: Date,
        calendar: Calendar = .current,
        entryCount: Int = 5
    ) -> [Date] {
        (0..<entryCount).compactMap { hourOffset in
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
        deepLinkBuilder: (Date) -> URL?
    ) -> WidgetMonthSummarySnapshot {
        let deepLinkURL = deepLinkBuilder(date)
        do {
            let totals = try SummaryCalculator.monthlyTotals(
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
        deepLinkBuilder: (Date) -> URL?
    ) -> WidgetNetIncomeSnapshot {
        let deepLinkURL = deepLinkBuilder(date)
        do {
            let totals = try SummaryCalculator.monthlyTotals(
                context: context,
                date: date
            )
            return .init(
                netIncomeText: totals.netIncome.asCurrency,
                isPositive: totals.netIncome.isPlus || totals.netIncome.isZero,
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
                item = try ItemService.nextItem(
                    context: context,
                    date: now
                )
            case .previous:
                item = try ItemService.previousItem(
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
            let deepLinkURL: URL? = {
                if let itemID = try? item.id.base64Encoded() {
                    return deepLinkBuilder.itemDeepLink(itemID)
                }
                return deepLinkBuilder.monthDeepLink(item.localDate)
            }()

            return .init(
                subtitleText: subtitle(for: direction),
                titleText: Formatting.shortDayTitle(from: item.localDate),
                detailText: item.content,
                amountText: amount.asCurrency,
                isPositive: amount.isPlus || amount.isZero,
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
