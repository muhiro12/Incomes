//
//  MainNavigationRouter.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import SwiftData
import SwiftUI

@MainActor
@Observable
final class MainNavigationRouter {
    var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    var yearTagID: Tag.ID?
    var selectedTag: Tag?
    var searchText = ""
    var predicate: ItemPredicate?
    var isSearchPresented = false
    var appliesInitialSearchText = false
    var sheetRoute: MainNavigationSheetRoute?
    var fullScreenRoute: MainNavigationFullScreenRoute?
    var settingsDestination: SettingsNavigationDestination?
    var itemDetailID: PersistentIdentifier?

    func loadState(context: ModelContext) throws {
        let state = try MainNavigationStateLoader.load(context: context)
        yearTagID = state.yearTag?.persistentModelID
        selectedTag = state.yearMonthTag
        if state.yearTag == nil {
            preferredCompactColumn = .sidebar
        } else if state.yearMonthTag == nil {
            preferredCompactColumn = .content
        } else {
            preferredCompactColumn = .detail
        }
    }

    func handleIncomingRoute(
        _ route: IncomesRoute?,
        context: ModelContext
    ) throws {
        guard let route else {
            return
        }
        try apply(
            route: route,
            context: context
        )
    }

    func navigate(
        to route: IncomesRoute,
        context: ModelContext
    ) throws {
        try apply(
            route: route,
            context: context
        )
    }

    func selectSearchPredicate(_ predicate: ItemPredicate?) {
        self.predicate = predicate
        appliesInitialSearchText = false
        guard isSearchPresented else {
            return
        }
        preferredCompactColumn = predicate == nil ? .content : .detail
    }

    func selectYearTagID(_ yearTagID: Tag.ID?) {
        self.yearTagID = yearTagID
        selectedTag = nil
        clearSearchState()
        preferredCompactColumn = yearTagID == nil ? .sidebar : .content
    }

    func syncPreferredCompactColumn(
        _ preferredCompactColumn: NavigationSplitViewColumn,
        isCompact: Bool
    ) {
        self.preferredCompactColumn = preferredCompactColumn

        guard isCompact else {
            return
        }

        if preferredCompactColumn == .sidebar {
            yearTagID = nil
            selectedTag = nil
            clearSearchState()
            return
        }

        if preferredCompactColumn == .content {
            if isSearchPresented {
                predicate = nil
            } else {
                selectedTag = nil
            }
        }
    }
}

private extension MainNavigationRouter {
    func apply(
        route: IncomesRoute,
        context: ModelContext
    ) throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: route,
            context: context
        )
        switch outcome {
        case let .destination(yearTagID, selectedTag):
            settingsDestination = nil
            self.yearTagID = yearTagID
            self.selectedTag = selectedTag
            clearSearchState()
            preferredCompactColumn = selectedTag == nil ? .content : .detail
        case .search(let query):
            settingsDestination = nil
            isSearchPresented = true
            searchText = query ?? .empty
            predicate = nil
            appliesInitialSearchText = query?.isNotEmpty == true
            preferredCompactColumn = .content
        case .settings:
            sheetRoute = .settings
            settingsDestination = .root
        case .settingsSubscription:
            sheetRoute = .settings
            settingsDestination = .subscription
        case .settingsLicense:
            sheetRoute = .settings
            settingsDestination = .license
        case .settingsDebug:
            sheetRoute = .settings
            settingsDestination = .debug
        case .yearlyDuplication:
            settingsDestination = nil
            sheetRoute = .yearlyDuplication
        case .duplicateTags:
            settingsDestination = nil
            fullScreenRoute = .duplicateTags
        case .orphanTags:
            settingsDestination = nil
            fullScreenRoute = .orphanTags
        case .itemDetail(let itemID):
            settingsDestination = nil
            itemDetailID = itemID
            sheetRoute = .itemDetail
        }
    }

    func clearSearchState() {
        isSearchPresented = false
        searchText = .empty
        predicate = nil
        appliesInitialSearchText = false
    }
}
