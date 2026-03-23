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
            self.yearTagID = yearTagID
            self.selectedTag = selectedTag
            clearSearchState()
            preferredCompactColumn = selectedTag == nil ? .content : .detail
        case .search(let query):
            isSearchPresented = true
            searchText = query ?? .empty
            predicate = nil
            preferredCompactColumn = .content
        case .settings:
            sheetRoute = .settings
            settingsDestination = nil
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
            sheetRoute = .yearlyDuplication
        case .duplicateTags:
            fullScreenRoute = .duplicateTags
        case .itemDetail(let itemID):
            itemDetailID = itemID
            sheetRoute = .itemDetail
        }
    }

    func clearSearchState() {
        isSearchPresented = false
        searchText = .empty
        predicate = nil
    }
}
