import Foundation
import SwiftData

/// Domain operations for resolving main navigation state and routes.
public enum MainNavigationOperations {
    /// Returns the canonical route for a selected year tag.
    public static func route(forYearTag tag: Tag) -> IncomesRoute? {
        IncomesContextMenuLinkBuilder.yearRoute(for: tag)
    }

    /// Returns the year summary route represented by a year tag.
    public static func yearSummaryRoute(forYearTag tag: Tag) -> IncomesRoute? {
        IncomesContextMenuLinkBuilder.yearSummaryRoute(for: tag)
    }

    /// Returns the month route represented by a year-month tag.
    public static func route(forYearMonthTag tag: Tag) -> IncomesRoute? {
        IncomesContextMenuLinkBuilder.monthRoute(for: tag)
    }

    /// Returns the preferred deep link for `route`.
    public static func preferredURL(for route: IncomesRoute?) -> URL? {
        IncomesContextMenuLinkBuilder.preferredURL(for: route)
    }

    /// Returns the preferred deep link for the month containing `date`.
    public static func preferredURL(
        forMonthContaining date: Date,
        calendar: Calendar = .current
    ) -> URL? {
        preferredURL(
            for: .month(
                year: calendar.component(.year, from: date),
                month: calendar.component(.month, from: date)
            )
        )
    }

    /// Returns the preferred item deep link for `item`.
    public static func preferredURL(for item: Item) -> URL? {
        IncomesContextMenuLinkBuilder.preferredURL(for: item)
    }

    /// Returns the default year and year-month selections that match `date`.
    public static func loadState(
        context: ModelContext,
        date: Date = .now
    ) throws -> MainNavigationState {
        try MainNavigationStateLoader.load(
            context: context,
            date: date
        )
    }

    /// Resolves `route` into the destination or modal state for main navigation.
    public static func execute(
        route: IncomesRoute,
        context: ModelContext
    ) throws -> MainNavigationRouteOutcome {
        try MainNavigationRouteExecutor.execute(
            route: route,
            context: context
        )
    }
}
