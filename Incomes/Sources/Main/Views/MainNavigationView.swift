//
//  MainNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import Foundation
import SwiftData
import SwiftUI

struct MainNavigationView: View {
    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.year), order: .reverse))
    private var yearTags: [Tag]

    @Binding private var incomingRoute: IncomesRoute?

    @StateObject private var router: MainNavigationRouter = .init()

    init(incomingRoute: Binding<IncomesRoute?> = .constant(nil)) {
        _incomingRoute = incomingRoute
    }

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
        NavigationSplitView {
            List(selection: yearTagSelection) {
                ForEach(yearTags, id: \.persistentModelID) { yearTag in
                    TagSummaryRow()
                        .environment(yearTag)
                        .tag(yearTag.persistentModelID)
                }
                .onDelete { indices in
                    Haptic.warning.impact()
                    router.isYearDeleteDialogPresented = true
                    router.willDeleteTags = indices.compactMap { index in
                        guard yearTags.indices.contains(index) else {
                            return nil
                        }
                        return yearTags[index]
                    }
                    router.willDeleteItems = TagService.resolveItemsForDeletion(
                        from: yearTags,
                        indices: indices
                    )
                }
                YearlyDuplicationPromoSection(
                    context: context,
                    yearTags: yearTags
                ) {
                    navigate(to: .yearlyDuplication)
                }
            }
            .confirmationDialog(
                Text("Delete"),
                isPresented: $router.isYearDeleteDialogPresented
            ) {
                Button(role: .destructive) {
                    do {
                        try ItemService.delete(
                            context: context,
                            items: router.willDeleteItems
                        )
                        if let selectedYearTag,
                           router.willDeleteTags.contains(where: { deletingTag in
                            deletingTag.name == selectedYearTag.name && deletingTag.typeID == selectedYearTag.typeID
                           }) {
                            router.yearTagID = nil
                        }
                        router.willDeleteItems = []
                        router.willDeleteTags = []
                        Haptic.success.impact()
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                } label: {
                    Text("Delete")
                }
                Button(role: .cancel) {
                    router.willDeleteItems = []
                    router.willDeleteTags = []
                } label: {
                    Text("Cancel")
                }
            } message: {
                Text("Are you sure you want to delete these items?")
            }
            .navigationTitle("Incomes")
            .toolbar {
                ToolbarItem {
                    Button("Settings", systemImage: "gear") {
                        navigate(to: .settings)
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
            Group {
                if router.isSearchPresented {
                    SearchListView(
                        selection: $router.predicate,
                        searchText: $router.searchText
                    )
                } else if let selectedYearTag {
                    HomeListView { route in
                        navigate(to: route)
                    }
                    .environment(selectedYearTag)
                }
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
            if router.isSearchPresented {
                SearchResultView(predicate: router.predicate ?? .none)
            } else if let selectedTag = router.selectedTag {
                ItemListGroup()
                    .environment(selectedTag)
            }
        }
        .sheet(
            item: $router.sheetRoute,
            onDismiss: {
                do {
                    try router.applyPendingRouteAfterSettingsDismissalIfNeeded(
                        context: context
                    )
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
        ) { sheetRoute in
            switch sheetRoute {
            case .settings:
                SettingsNavigationView(
                    incomingDestination: $router.settingsDestination
                ) { route in
                    do {
                        try router.navigateFromSettings(
                            to: route,
                            context: context
                        )
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
            case .yearlyDuplication:
                NavigationStack {
                    YearlyDuplicationView()
                }
            case .introduction:
                IntroductionNavigationView()
            }
        }
        .fullScreenCover(item: $router.fullScreenRoute) { fullScreenRoute in
            switch fullScreenRoute {
            case .duplicateTags:
                DuplicateTagNavigationView()
            }
        }
        .onChange(of: incomingRoute) {
            do {
                try handleIncomingRoute()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        .task {
            do {
                try router.loadState(
                    context: context
                )
            } catch {
                assertionFailure(error.localizedDescription)
            }

            do {
                try handleIncomingRoute()
                try router.applyPendingRouteIfNeeded(context: context)
            } catch {
                assertionFailure(error.localizedDescription)
            }

            await PhoneWatchBridge.shared.activate(modelContext: context)
        }
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
        guard let year = Int(yearTag.name),
              1...9_999 ~= year else {
            router.selectYearTagID(yearTagID)
            return
        }
        navigate(to: .year(year))
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

    func handleIncomingRoute() throws {
        guard let route = incomingRoute else {
            return
        }
        try router.handleIncomingRoute(route, context: context)
        incomingRoute = nil
    }
}

enum MainNavigationSheetRoute: String, Identifiable {
    case settings
    case yearlyDuplication
    case introduction

    var id: String {
        rawValue
    }
}

enum MainNavigationFullScreenRoute: String, Identifiable {
    case duplicateTags

    var id: String {
        rawValue
    }
}

@MainActor
final class MainNavigationRouter: ObservableObject {
    @Published var yearTagID: Tag.ID?
    @Published var selectedTag: Tag?
    @Published var searchText = ""
    @Published var predicate: ItemPredicate?
    @Published var isSearchPresented = false
    @Published var sheetRoute: MainNavigationSheetRoute?
    @Published var fullScreenRoute: MainNavigationFullScreenRoute?
    @Published var settingsDestination: SettingsNavigationDestination?
    @Published var isYearDeleteDialogPresented = false
    @Published var willDeleteItems: [Item] = []
    @Published var willDeleteTags: [Tag] = []

    private var hasLoaded = false
    private var pendingRoute: IncomesRoute?
    private var pendingRouteAfterSettingsDismissal: IncomesRoute?

    func loadState(context: ModelContext) throws {
        let state = try MainNavigationStateLoader.load(context: context)
        if hasLoaded == false {
            hasLoaded = true
            if state.isIntroductionPresented {
                sheetRoute = .introduction
            }
        }
        yearTagID = state.yearTag?.persistentModelID
        selectedTag = state.yearMonthTag
    }

    func handleIncomingRoute(
        _ route: IncomesRoute?,
        context: ModelContext
    ) throws {
        guard let route else {
            return
        }
        if hasLoaded {
            try apply(route: route, context: context)
        } else {
            pendingRoute = route
        }
    }

    func navigate(
        to route: IncomesRoute,
        context: ModelContext
    ) throws {
        try apply(route: route, context: context)
    }

    func navigateFromSettings(
        to route: IncomesRoute,
        context: ModelContext
    ) throws {
        if isSettingsPresented && route.isSettingsScopeRoute {
            try apply(route: route, context: context)
        } else if isSettingsPresented {
            pendingRouteAfterSettingsDismissal = route
            sheetRoute = nil
        } else {
            try apply(route: route, context: context)
        }
    }

    func applyPendingRouteIfNeeded(context: ModelContext) throws {
        guard hasLoaded,
              let pendingRoute else {
            return
        }
        try apply(route: pendingRoute, context: context)
        self.pendingRoute = nil
    }

    func applyPendingRouteAfterSettingsDismissalIfNeeded(
        context: ModelContext
    ) throws {
        guard isSettingsPresented == false,
              let pendingRouteAfterSettingsDismissal else {
            return
        }
        self.pendingRouteAfterSettingsDismissal = nil
        try apply(route: pendingRouteAfterSettingsDismissal, context: context)
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
        case .destination(let yearTagID, let selectedTag):
            self.yearTagID = yearTagID
            self.selectedTag = selectedTag
            clearSearchState()
        case .search(let query):
            isSearchPresented = true
            searchText = query ?? .empty
            predicate = nil
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
        case .introduction:
            sheetRoute = .introduction
        case .duplicateTags:
            fullScreenRoute = .duplicateTags
        }
    }

    func clearSearchState() {
        isSearchPresented = false
        searchText = .empty
        predicate = nil
    }

    var isSettingsPresented: Bool {
        sheetRoute == .settings
    }

    func selectYearTagID(_ yearTagID: Tag.ID?) {
        self.yearTagID = yearTagID
        selectedTag = nil
        clearSearchState()
    }
}

private extension IncomesRoute {
    var isSettingsScopeRoute: Bool {
        switch self {
        case .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug:
            return true
        case .home,
             .yearSummary,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .year,
             .month,
             .search:
            return false
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    MainNavigationView()
}
