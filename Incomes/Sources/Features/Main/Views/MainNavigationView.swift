//
//  MainNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import Foundation
import MHPlatform
import SwiftData
import SwiftUI

struct MainNavigationView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(IncomesTipController.self)
    private var tipController

    private let ledgerMenu: LedgerSelectionMenu?

    @Query private var queriedYearTags: [Tag]

    private var yearTags: [Tag] {
        queriedYearTags.filter { tag in
            !TagQueryOperations.items(for: tag, ledgerIdentifier: router.ledgerIdentifier).isEmpty
        }
    }

    // Scene storage lives as long as the scene session, so a closed window
    // starts again from today's month while a relaunched scene keeps its place.
    @SceneStorage("MainNavigation.restorableRoute")
    private var restorableRouteURL: URL?

    @State private var router: MainNavigationRouter = .init()
    @State private var settingsCoordinator: MainNavigationSettingsCoordinator = .init()
    @State private var yearDeletionModel: MainNavigationYearDeletionModel = .init()

    private var selectedYearTag: Tag? {
        guard let yearTagID = router.yearTagID else {
            return nil
        }
        return yearTags.first { yearTag in
            yearTag.persistentModelID == yearTagID
        }
    }

    private var restorableRoute: IncomesRoute? {
        MainNavigationOperations.restorableRoute(
            yearTag: selectedYearTag,
            selectedTag: router.selectedTag
        )
    }

    private var tagSelection: Binding<Tag.ID?> {
        .init(
            get: {
                router.selectedTag?.persistentModelID
            },
            set: { tagID in
                handleTagSelection(tagID)
            }
        )
    }

    var body: some View {
        @Bindable var router = router

        NavigationSplitView {
            MainNavigationSidebarColumn(
                yearTags: yearTags,
                selectedYearTag: selectedYearTag,
                tagSelection: tagSelection,
                onNavigate: enqueueNavigation
            )
            .searchable(text: $router.searchText, isPresented: $router.isSearchPresented)
            .navigationTitle(
                router.isSearchActive ? String(localized: "Search") : ledgerMenu?.selectedName ?? "Incomes"
            )
            .toolbar {
                MainNavigationSidebarToolbarContent(
                    isCompact: horizontalSizeClass == .compact,
                    ledgerMenu: ledgerMenu,
                    openSearch: {
                        enqueueNavigation(to: .search(query: nil))
                    },
                    openSettings: {
                        enqueueNavigation(to: .settings)
                    }
                )
            }
        } detail: {
            MainNavigationDetailColumn(hasAnyYears: !yearTags.isEmpty)
        }
        .sheet(
            item: $router.sheetRoute,
            onDismiss: {
                Task {
                    applyPendingRouteAfterSettingsDismissalIfNeeded()
                }
            },
            content: { sheetRoute in
                MainNavigationSheetPresenter(
                    route: sheetRoute,
                    settingsDestination: $router.settingsDestination
                ) { route in
                    navigateFromSettings(to: route)
                }
            }
        )
        .fullScreenCover(item: $router.fullScreenRoute) { fullScreenRoute in
            switch fullScreenRoute {
            case .duplicateTags:
                DuplicateTagNavigationView()
            case .orphanTags:
                OrphanTagNavigationView()
            }
        }
        .onChange(of: yearTags) {
            tipController.refreshHasAnyItems(!yearTags.isEmpty)
            if let yearTagID = router.yearTagID,
               !yearTags.contains(where: { $0.persistentModelID == yearTagID }) {
                router.selectYearTagID(nil)
            }
        }
        .onChange(of: router.isSearchPresented) {
            handleSearchPresentationChange()
        }
        .onChange(of: restorableRoute) {
            restorableRouteURL = MainNavigationOperations.restorationURL(for: restorableRoute)
        }
        .task {
            loadInitialState()

            tipController.refreshHasAnyItems(!yearTags.isEmpty)

            await IncomesMutationWorkflow.refreshNotificationSchedule(
                notificationService: notificationService
            )
            await PhoneWatchBridge.shared.activate(
                modelContext: context,
                logger: watchSyncLogger
            )
        }
        .environment(router)
        .environment(settingsCoordinator)
        .environment(yearDeletionModel)
    }

    init(
        ledgerIdentifier: LedgerIdentifier = .default,
        ledgerMenu: LedgerSelectionMenu? = nil,
        router: MainNavigationRouter? = nil
    ) {
        self.ledgerMenu = ledgerMenu
        _queriedYearTags = .init(.tags(.typeIs(.year), order: .reverse))
        _router = .init(initialValue: router ?? .init(ledgerIdentifier: ledgerIdentifier))
    }
}

private extension MainNavigationView {
    func handleTagSelection(_ tagID: Tag.ID?) {
        // The split view can clear a list selection while collapsing columns.
        // Back navigation changes the visible column, not the selected place.
        guard let tagID,
              let tag = try? TagQueryOperations.getByPersistentID(context: context, persistentID: tagID),
              !TagQueryOperations.items(for: tag, ledgerIdentifier: router.ledgerIdentifier).isEmpty else {
            return
        }
        let route: IncomesRoute?
        switch tag.type {
        case .year:
            route = MainNavigationOperations.yearSummaryRoute(forYearTag: tag)
        case .yearMonth:
            route = MainNavigationOperations.route(forYearMonthTag: tag)
            tipController.donateDidOpenMonth()
        default:
            route = nil
        }
        if let route {
            enqueueNavigation(to: route)
        }
    }

    func enqueueNavigation(to route: IncomesRoute) {
        navigate(to: route)
    }

    func loadInitialState() {
        do {
            try router.loadInitialState(
                restoredRoute: restorableRouteURL.flatMap(
                    MainNavigationOperations.restorableRoute(from:)
                ),
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func navigate(to route: IncomesRoute) {
        do {
            try router.navigate(
                to: route,
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func navigateFromSettings(to route: IncomesRoute) {
        do {
            try settingsCoordinator.navigateFromSettings(
                to: route,
                isSettingsPresented: router.sheetRoute == .settings,
                applyRoute: {
                    try router.navigate(
                        to: route,
                        context: context
                    )
                },
                dismissSettings: {
                    router.sheetRoute = nil
                }
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func applyPendingRouteAfterSettingsDismissalIfNeeded() {
        do {
            try settingsCoordinator.applyPendingRouteAfterSettingsDismissalIfNeeded(
                isSettingsPresented: router.sheetRoute == .settings
            ) { route in
                try router.navigate(
                    to: route,
                    context: context
                )
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func handleSearchPresentationChange() {
        if router.isSearchPresented {
            router.beginSearch()
            tipController.donateDidOpenSearch()
        } else if router.isSearchActive {
            router.dismissSearch()
        }
    }
}

private extension MainNavigationView {
    var watchSyncLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.watchSync,
            source: #fileID
        )
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    MainNavigationView()
}
