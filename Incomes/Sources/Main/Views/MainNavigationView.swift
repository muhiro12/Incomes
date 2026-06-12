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
    @Environment(IncomesRouteInbox.self)
    private var routeInbox

    @Query(.tags(.typeIs(.year), order: .reverse))
    private var yearTags: [Tag]

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

    private var yearTagSelection: Binding<Tag.ID?> {
        .init(
            get: {
                router.yearTagID
            },
            set: { yearTagID in
                handleYearTagSelection(yearTagID)
            }
        )
    }

    var body: some View {
        @Bindable var router = router

        let compactColumnSelection = Binding<NavigationSplitViewColumn>(
            get: {
                self.router.preferredCompactColumn
            },
            set: { preferredCompactColumn in
                self.router.syncPreferredCompactColumn(
                    preferredCompactColumn,
                    isCompact: horizontalSizeClass == .compact
                )
            }
        )

        NavigationSplitView(preferredCompactColumn: compactColumnSelection) {
            MainNavigationSidebarView(
                yearTags: yearTags,
                selectedYearTag: selectedYearTag,
                yearTagSelection: yearTagSelection
            ) { route in
                enqueueNavigation(to: route)
            }
            .navigationTitle("Incomes")
            .toolbar {
                ToolbarItemGroup {
                    if horizontalSizeClass == .compact {
                        Button("Search", systemImage: "magnifyingglass") {
                            enqueueNavigation(to: .search(query: nil))
                        }
                    }
                    Button("Settings", systemImage: "gear") {
                        enqueueNavigation(to: .settings)
                    }
                }
            }
            .toolbar {
                StatusToolbarItem("Today: \(Date.now.stringValue(.yyyyMMMd))")
            }
            .toolbar {
                SpacerToolbarItem(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    CreateItemButton()
                }
            }
        } content: {
            MainNavigationContentColumn(
                hasAnyYears: !yearTags.isEmpty,
                selectedYearTag: selectedYearTag
            ) { route in
                enqueueNavigation(to: route)
            }
            .searchable(text: $router.searchText, isPresented: $router.isSearchPresented)
            .toolbar {
                StatusToolbarItem("Today: \(Date.now.stringValue(.yyyyMMMd))")
            }
            .toolbar {
                if #available(iOS 26.0, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                }
                SpacerToolbarItem(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    if let selectedYearTag {
                        CreateItemButton()
                            .environment(selectedYearTag)
                    } else {
                        CreateItemButton()
                    }
                }
            }
        } detail: {
            MainNavigationDetailColumn()
        }
        .sheet(
            item: $router.sheetRoute,
            onDismiss: {
                router.itemDetailID = nil
                Task {
                    applyPendingRouteAfterSettingsDismissalIfNeeded()
                }
            },
            content: { sheetRoute in
                MainNavigationSheetPresenter(
                    route: sheetRoute,
                    itemDetailID: router.itemDetailID,
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
        .mhRouteHandler(routeInbox) { route in
            try router.handleIncomingRoute(
                route,
                context: context
            )
        }
        .onChange(of: yearTags) {
            tipController.refreshHasAnyItems(!yearTags.isEmpty)
        }
        .onChange(of: router.isSearchPresented) {
            if router.isSearchPresented {
                tipController.donateDidOpenSearch()
            }
        }
        .task {
            loadState()

            tipController.refreshHasAnyItems(!yearTags.isEmpty)

            await PhoneWatchBridge.shared.activate(
                modelContext: context,
                logger: watchSyncLogger
            )
        }
        .environment(router)
        .environment(settingsCoordinator)
        .environment(yearDeletionModel)
    }
}

private extension MainNavigationView {
    func handleYearTagSelection(_ yearTagID: Tag.ID?) {
        guard let yearTagID else {
            router.selectYearTagID(nil)
            return
        }
        guard let yearTag = yearTags.first(where: { yearTag in
            yearTag.persistentModelID == yearTagID
        }) else {
            return
        }
        if let route = MainNavigationOperations.route(forYearTag: yearTag) {
            enqueueNavigation(to: route)
        } else {
            router.selectYearTagID(yearTagID)
        }
    }

    func enqueueNavigation(to route: IncomesRoute) {
        navigate(to: route)
    }

    func loadState() {
        do {
            try router.loadState(
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
