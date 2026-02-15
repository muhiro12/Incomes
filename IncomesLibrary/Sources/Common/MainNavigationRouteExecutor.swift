import Foundation
import SwiftData

/// Resolves an `IncomesRoute` into a navigation outcome for main navigation UI state.
public enum MainNavigationRouteExecutor {
    public static func execute(
        route: IncomesRoute,
        context: ModelContext
    ) throws -> MainNavigationRouteOutcome {
        switch route {
        case .home:
            let state = try MainNavigationStateLoader.load(context: context)
            return .destination(
                yearTagID: state.yearTag?.persistentModelID,
                selectedTag: state.yearMonthTag
            )
        case .settings:
            return .settings
        case .settingsSubscription:
            return .settingsSubscription
        case .settingsLicense:
            return .settingsLicense
        case .settingsDebug:
            return .settingsDebug
        case .yearSummary(let year):
            return .destination(
                yearTagID: try resolveYearTagID(
                    context: context,
                    year: year
                ),
                selectedTag: try resolveYearTag(
                    context: context,
                    year: year
                )
            )
        case .yearlyDuplication:
            return .yearlyDuplication
        case .introduction:
            return .introduction
        case .duplicateTags:
            return .duplicateTags
        case .year(let year):
            return .destination(
                yearTagID: try resolveYearTagID(
                    context: context,
                    year: year
                ),
                selectedTag: nil
            )
        case .month(let year, let month):
            let yearTagID = try resolveYearTagID(
                context: context,
                year: year
            )
            let yearMonthTag = try resolveYearMonthTag(
                context: context,
                year: year,
                month: month
            )
            return .destination(
                yearTagID: yearTagID,
                selectedTag: yearMonthTag
            )
        case .search(let query):
            return .search(query: query)
        }
    }
}

public enum MainNavigationRouteOutcome {
    case destination(
            yearTagID: Tag.ID?,
            selectedTag: Tag?
         )
    case search(query: String?)
    case settings
    case settingsSubscription
    case settingsLicense
    case settingsDebug
    case yearlyDuplication
    case introduction
    case duplicateTags
}

private extension MainNavigationRouteExecutor {
    static func resolveYearTagID(
        context: ModelContext,
        year: Int
    ) throws -> Tag.ID? {
        let yearTagName = String(format: "%04d", year)
        let yearTag = try TagService.getByName(
            context: context,
            name: yearTagName,
            type: .year
        )
        return yearTag?.persistentModelID
    }

    static func resolveYearMonthTag(
        context: ModelContext,
        year: Int,
        month: Int
    ) throws -> Tag? {
        let yearMonthTagName = String(format: "%04d%02d", year, month)
        return try TagService.getByName(
            context: context,
            name: yearMonthTagName,
            type: .yearMonth
        )
    }

    static func resolveYearTag(
        context: ModelContext,
        year: Int
    ) throws -> Tag? {
        let yearTagName = String(format: "%04d", year)
        return try TagService.getByName(
            context: context,
            name: yearTagName,
            type: .year
        )
    }
}
