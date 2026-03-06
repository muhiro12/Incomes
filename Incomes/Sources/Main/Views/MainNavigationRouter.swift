//
//  MainNavigationRouter.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import MHPlatform
import SwiftData
import SwiftUI

@MainActor
final class MainNavigationRouter: ObservableObject {
    @Published var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    @Published var yearTagID: Tag.ID?
    @Published var selectedTag: Tag?
    @Published var searchText = ""
    @Published var predicate: ItemPredicate?
    @Published var isSearchPresented = false
    @Published var sheetRoute: MainNavigationSheetRoute?
    @Published var fullScreenRoute: MainNavigationFullScreenRoute?
    @Published var settingsDestination: SettingsNavigationDestination?
    @Published var itemDetailID: PersistentIdentifier?
    @Published var isYearDeleteDialogPresented = false
    @Published var willDeleteItems: [Item] = []
    @Published var willDeleteTags: [Tag] = []

    private let routeCoordinator: MHRouteCoordinator<IncomesRoute, IncomesRoute> = .init(
        executor: .init(
            resolve: { route in
                route
            },
            apply: { _ in
                // Route application stays app-specific.
            }
        ),
        isDuplicate: ==
    )

    private var pendingRouteAfterSettingsDismissal: IncomesRoute?

    private var isSettingsPresented: Bool {
        sheetRoute == .settings
    }

    func prepareYearDeletion(
        from yearTags: [Tag],
        indices: IndexSet
    ) {
        willDeleteTags = TagService.resolveTagsForDeletion(
            from: yearTags,
            indices: indices
        )
        willDeleteItems = TagService.resolveItemsForDeletion(
            from: yearTags,
            indices: indices
        )
        isYearDeleteDialogPresented = willDeleteTags.isNotEmpty
    }

    func completeYearDeletion(selectedYearTag: Tag?) {
        if let selectedYearTag,
           TagService.containsEquivalentTag(
            selectedYearTag,
            in: willDeleteTags
           ) {
            yearTagID = nil
        }
        clearYearDeletion()
    }

    func clearYearDeletion() {
        isYearDeleteDialogPresented = false
        willDeleteItems = []
        willDeleteTags = []
    }

    func loadState(context: ModelContext) async throws {
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
        await routeCoordinator.setReadiness(true)
    }

    func handleIncomingRoute(
        _ route: IncomesRoute?,
        context: ModelContext
    ) async throws {
        guard let route else {
            return
        }
        try await submit(route, context: context)
    }

    func navigate(
        to route: IncomesRoute,
        context: ModelContext
    ) async throws {
        try await submit(route, context: context)
    }

    func navigateFromSettings(
        to route: IncomesRoute,
        context: ModelContext
    ) async throws {
        if isSettingsPresented, route.isSettingsScopeRoute {
            try await submit(route, context: context)
        } else if isSettingsPresented {
            pendingRouteAfterSettingsDismissal = route
            sheetRoute = nil
        } else {
            try await submit(route, context: context)
        }
    }

    func applyPendingRouteIfNeeded(context: ModelContext) async throws {
        guard let executionOutcome = try await routeCoordinator.applyPendingIfReady() else {
            return
        }
        try apply(
            executionOutcome,
            context: context
        )
    }

    func applyPendingRouteAfterSettingsDismissalIfNeeded(
        context: ModelContext
    ) throws {
        guard isSettingsPresented == false,
              let pendingRouteAfterSettingsDismissal else {
            return
        }
        self.pendingRouteAfterSettingsDismissal = nil
        try apply(
            route: pendingRouteAfterSettingsDismissal,
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
    func submit(
        _ route: IncomesRoute,
        context: ModelContext
    ) async throws {
        let executionOutcome = try await routeCoordinator.submit(route)
        try apply(
            executionOutcome,
            context: context
        )
    }

    func apply(
        _ executionOutcome: MHRouteExecutionOutcome<IncomesRoute>,
        context: ModelContext
    ) throws {
        switch executionOutcome {
        case .applied(let route):
            try apply(
                route: route,
                context: context
            )
        case .queued,
             .deduplicated:
            return
        }
    }

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
