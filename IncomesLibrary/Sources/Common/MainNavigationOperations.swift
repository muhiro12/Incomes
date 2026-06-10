import Foundation
import SwiftData

/// Domain operations for resolving main navigation state and routes.
public enum MainNavigationOperations {
    /// Returns the canonical route for a selected year tag.
    public static func route(forYearTag tag: Tag) -> IncomesRoute? {
        guard tag.type == .year,
              let year = Int(tag.name),
              YearMonthComponentRules.isValidYear(year) else {
            return nil
        }
        return .year(year)
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
