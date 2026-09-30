import Foundation

public extension MainNavigationOperations {
    /// Returns the semantic route that describes the current main selection,
    /// or `nil` when no year is selected and today's default applies.
    ///
    /// Only year, year summary, and month selections are restorable. Search,
    /// item detail, settings, and maintenance screens are session-only.
    static func restorableRoute(
        yearTag: Tag?,
        selectedTag: Tag?
    ) -> IncomesRoute? {
        if let selectedTag {
            switch selectedTag.type {
            case .yearMonth:
                return route(forYearMonthTag: selectedTag)
            case .year:
                return yearSummaryRoute(forYearTag: selectedTag)
            default:
                break
            }
        }
        guard let yearTag else {
            return nil
        }
        return route(forYearTag: yearTag)
    }

    /// Encodes a restorable route as its canonical deep link.
    static func restorationURL(for route: IncomesRoute?) -> URL? {
        guard let route,
              isRestorable(route) else {
            return nil
        }
        return preferredURL(for: route)
    }

    /// Decodes a restorable route from its canonical deep link. Any other
    /// route, including one saved by a future version, is ignored.
    static func restorableRoute(from url: URL) -> IncomesRoute? {
        guard let route = IncomesRouteParser.parse(url: url),
              isRestorable(route) else {
            return nil
        }
        return route
    }
}

private extension MainNavigationOperations {
    static func isRestorable(_ route: IncomesRoute) -> Bool {
        switch route {
        case .year,
             .yearSummary,
             .month:
            true
        case .home,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .duplicateTags,
             .orphanTags,
             .item,
             .search:
            false
        }
    }
}
