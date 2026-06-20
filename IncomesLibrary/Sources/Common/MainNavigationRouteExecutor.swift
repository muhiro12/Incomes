import Foundation
import SwiftData

enum MainNavigationRouteExecutor {
    static func execute(
        route: IncomesRoute,
        context: ModelContext
    ) throws -> MainNavigationRouteOutcome {
        switch route {
        case .home,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .duplicateTags,
             .orphanTags:
            return try executeStaticRoute(route, context: context)
        case .yearSummary,
             .year,
             .month:
            return try executeDateRoute(route, context: context)
        case .item,
             .search:
            return try executeEntityRoute(route, context: context)
        }
    }
}

private extension MainNavigationRouteExecutor {
    static func executeStaticRoute(
        _ route: IncomesRoute,
        context: ModelContext
    ) throws -> MainNavigationRouteOutcome {
        switch route {
        case .home:
            return try fallbackHomeDestination(context: context)
        case .settings:
            return .settings
        case .settingsSubscription:
            return .settingsSubscription
        case .settingsLicense:
            return .settingsLicense
        case .settingsDebug:
            return .settingsDebug
        case .yearlyDuplication:
            return .yearlyDuplication
        case .duplicateTags:
            return .duplicateTags
        case .orphanTags:
            return .orphanTags
        default:
            assertionFailure()
            return try fallbackHomeDestination(context: context)
        }
    }

    static func executeDateRoute(
        _ route: IncomesRoute,
        context: ModelContext
    ) throws -> MainNavigationRouteOutcome {
        switch route {
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
        default:
            assertionFailure()
            return try fallbackHomeDestination(context: context)
        }
    }

    static func executeEntityRoute(
        _ route: IncomesRoute,
        context: ModelContext
    ) throws -> MainNavigationRouteOutcome {
        switch route {
        case .item(let itemID):
            guard let persistentID = try? PersistentIdentifierCoder.decode(itemID) else {
                return try fallbackHomeDestination(context: context)
            }
            guard try context.fetchFirst(
                .items(.idIs(persistentID))
            ) != nil else {
                return try fallbackHomeDestination(context: context)
            }
            return .itemDetail(itemID: persistentID)
        case .search(let query):
            return .search(
                query: query,
                predicate: try resolveSearchPredicate(
                    context: context,
                    query: query
                )
            )
        default:
            assertionFailure()
            return try fallbackHomeDestination(context: context)
        }
    }

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
        let yearTag = try TagQueryOperations.getByName(
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
        return try TagQueryOperations.getByName(
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
        return try TagQueryOperations.getByName(
            context: context,
            name: yearTagName,
            type: .year
        )
    }

    static func resolveSearchPredicate(
        context: ModelContext,
        query: String?
    ) throws -> ItemPredicate? {
        guard let query = query?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty else {
            return nil
        }

        let contentTags = try context.fetch(.tags(.typeIs(.content)))
        let matchingTags = TagQueryOperations.matchingDisplayNameTags(
            in: contentTags,
            query: query
        )
        let exactMatches = matchingTags.filter { tag in
            tag.displayName.localizedStandardCompare(query) == .orderedSame
        }
        let resolvedMatches = exactMatches.isEmpty ? matchingTags : exactMatches

        guard resolvedMatches.count == 1,
              let matchingTag = resolvedMatches.first else {
            return nil
        }

        return .tagIs(matchingTag)
    }
}
