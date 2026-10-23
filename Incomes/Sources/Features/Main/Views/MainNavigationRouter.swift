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
    let ledgerIdentifier: LedgerIdentifier

    var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    var yearTagID: Tag.ID?
    var selectedTag: Tag?
    var selectedItemID: PersistentIdentifier?
    var expandedYearTagIDs: Set<Tag.ID> = []
    var searchText = ""
    var predicate: ItemPredicate?
    var isSearchActive = false
    var isSearchPresented = false
    var appliesInitialSearchText = false
    var sheetRoute: MainNavigationSheetRoute?
    var fullScreenRoute: MainNavigationFullScreenRoute?
    var settingsDestination: SettingsNavigationDestination?

    @ObservationIgnored private var hasAppliedIncomingRoute = false

    init(ledgerIdentifier: LedgerIdentifier = .default) {
        self.ledgerIdentifier = ledgerIdentifier
    }

    /// Selects today's year and month, then the selection the scene restored.
    /// An incoming route from a link, widget, notification, or intent always
    /// wins, whichever arrives first.
    func loadInitialState(
        restoredRoute: IncomesRoute?,
        context: ModelContext
    ) throws {
        guard !hasAppliedIncomingRoute else {
            return
        }
        try loadState(context: context)
        guard let restoredRoute,
              case let .destination(yearTagID, selectedTag) = try MainNavigationOperations.execute(
                route: restoredRoute,
                context: context,
                ledgerIdentifier: ledgerIdentifier
              ),
              let yearTagID else {
            // A deleted year keeps today's default instead of an empty selection.
            return
        }
        self.yearTagID = yearTagID
        self.selectedTag = selectedTag
        expandedYearTagIDs.insert(yearTagID)
        preferredCompactColumn = selectedTag == nil ? .sidebar : .content
    }

    func loadState(context: ModelContext) throws {
        let state = try MainNavigationOperations.loadState(context: context, ledgerIdentifier: ledgerIdentifier)
        yearTagID = state.yearTag?.persistentModelID
        selectedTag = state.yearMonthTag
        selectedItemID = nil
        if let yearTagID {
            expandedYearTagIDs.insert(yearTagID)
        }
        preferredCompactColumn = selectedTag == nil ? .sidebar : .content
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
        hasAppliedIncomingRoute = true
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
        selectedItemID = nil
        appliesInitialSearchText = false
        guard isSearchActive else {
            return
        }
        preferredCompactColumn = predicate == nil ? .sidebar : .content
    }

    func selectYearTagID(_ yearTagID: Tag.ID?) {
        self.yearTagID = yearTagID
        selectedTag = nil
        selectedItemID = nil
        if let yearTagID {
            expandedYearTagIDs.insert(yearTagID)
        }
        clearSearchState()
        preferredCompactColumn = .sidebar
    }

    func selectItemID(_ itemID: PersistentIdentifier?) {
        selectedItemID = itemID
        preferredCompactColumn = itemID == nil ? .content : .detail
    }

    func beginSearch() {
        guard !isSearchActive else {
            return
        }
        isSearchActive = true
        selectedItemID = nil
        preferredCompactColumn = .sidebar
    }

    func dismissSearch() {
        clearSearchState()
        selectedItemID = nil
        preferredCompactColumn = selectedTag == nil ? .sidebar : .content
    }

    func syncPreferredCompactColumn(
        _ preferredCompactColumn: NavigationSplitViewColumn
    ) {
        self.preferredCompactColumn = preferredCompactColumn
    }
}

private extension MainNavigationRouter {
    func apply(
        route: IncomesRoute,
        context: ModelContext
    ) throws {
        let outcome = try MainNavigationOperations.execute(
            route: route,
            context: context,
            ledgerIdentifier: ledgerIdentifier
        )
        switch outcome {
        case let .destination(yearTagID, selectedTag):
            selectDestination(yearTagID: yearTagID, selectedTag: selectedTag)
        case let .search(query, predicate):
            settingsDestination = nil
            isSearchActive = true
            isSearchPresented = true
            searchText = query ?? ""
            self.predicate = predicate
            selectedItemID = nil
            appliesInitialSearchText = predicate == nil && query?.isEmpty == false
            preferredCompactColumn = predicate == nil ? .sidebar : .content
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
            try selectItemDestination(itemID, context: context)
        }
    }

    func selectDestination(yearTagID: Tag.ID?, selectedTag: Tag?) {
        settingsDestination = nil
        self.yearTagID = yearTagID
        self.selectedTag = selectedTag
        selectedItemID = nil
        if let yearTagID {
            expandedYearTagIDs.insert(yearTagID)
        }
        clearSearchState()
        preferredCompactColumn = selectedTag == nil ? .sidebar : .content
    }

    func selectItemDestination(_ itemID: PersistentIdentifier, context: ModelContext) throws {
        guard let item = try ItemQueryOperations.item(context: context, persistentID: itemID),
              item.ledgerIdentifier == ledgerIdentifier else {
            return
        }
        let state = try MainNavigationOperations.loadState(
            context: context,
            date: item.localDate,
            ledgerIdentifier: ledgerIdentifier
        )
        yearTagID = state.yearTag?.persistentModelID
        selectedTag = state.yearMonthTag
        if let yearTagID {
            expandedYearTagIDs.insert(yearTagID)
        }
        clearSearchState()
        selectItemID(itemID)
    }

    func clearSearchState() {
        isSearchActive = false
        isSearchPresented = false
        searchText = ""
        predicate = nil
        appliesInitialSearchText = false
    }
}
