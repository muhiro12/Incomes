import Foundation
import SwiftData

/// Resolves an `IncomesRoute` into a navigation outcome for main navigation UI state.
public enum MainNavigationRouteExecutor {
    /// Resolves `route` into the destination or modal state for main navigation.
    public static func execute( // swiftlint:disable:this cyclomatic_complexity function_body_length
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
        case let .month(year, month):
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
        case .item(let itemID):
            guard let persistentID = try? PersistentIdentifier(
                base64Encoded: itemID
            ) else {
                return try fallbackHomeDestination(context: context)
            }
            guard try context.fetchFirst(
                .items(.idIs(persistentID))
            ) != nil else {
                return try fallbackHomeDestination(context: context)
            }
            return .itemDetail(itemID: persistentID)
        case .search(let query):
            return .search(query: query)
        }
    }
}

private extension MainNavigationRouteExecutor {
    static func fallbackHomeDestination(
        context: ModelContext
    ) throws -> MainNavigationRouteOutcome {
        let state = try MainNavigationStateLoader.load(context: context)
        return .destination(
            yearTagID: state.yearTag?.persistentModelID,
            selectedTag: state.yearMonthTag
        )
    }

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
