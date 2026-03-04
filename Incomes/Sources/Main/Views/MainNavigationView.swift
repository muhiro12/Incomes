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
    @Environment(IncomesTipController.self)
    private var tipController

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

    private var searchPredicateSelection: Binding<ItemPredicate?> {
        .init(
            get: {
                router.predicate
            },
            set: { predicate in
                router.selectSearchPredicate(predicate)
            }
        )
    }

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $router.preferredCompactColumn) {
            Group {
                if yearTags.isEmpty {
                    CreateItemButton()
                } else {
                    List(selection: yearTagSelection) {
                        ForEach(yearTags, id: \.persistentModelID) { yearTag in
                            TagSummaryRow()
                                .environment(yearTag)
                                .tag(yearTag.persistentModelID)
                        }
                        .onDelete { indices in
                            Haptic.warning.impact()
                            router.prepareYearDeletion(
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
                        router.completeYearDeletion(
                            selectedYearTag: selectedYearTag
                        )
                        Haptic.success.impact()
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                } label: {
                    Text("Delete")
                }
                Button(role: .cancel) {
                    router.clearYearDeletion()
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
                        selection: searchPredicateSelection,
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
                router.itemDetailID = nil
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
            case .itemDetail:
                deepLinkedItemNavigationView()
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
        .onChange(of: yearTags) {
            tipController.refreshHasAnyItems(!yearTags.isEmpty)
        }
        .onChange(of: router.isSearchPresented) {
            if router.isSearchPresented {
                tipController.donateDidOpenSearch()
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

            tipController.refreshHasAnyItems(!yearTags.isEmpty)

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

    @ViewBuilder
    func deepLinkedItemNavigationView() -> some View {
        if let itemDetailID = router.itemDetailID,
           let item = try? context.fetchFirst(
            .items(.idIs(itemDetailID))
           ) {
            ItemNavigationView()
                .environment(item)
        } else {
            NavigationStack {
                Text("Item not found")
                    .navigationTitle("Item")
                    .toolbar {
                        ToolbarItem {
                            CloseButton()
                        }
                    }
            }
        }
    }
}

enum MainNavigationSheetRoute: String, Identifiable {
    case settings
    case yearlyDuplication
    case itemDetail

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

    private var hasLoaded = false
    private var pendingRoute: IncomesRoute?
    private var pendingRouteAfterSettingsDismissal: IncomesRoute?

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

    func loadState(context: ModelContext) throws {
        let state = try MainNavigationStateLoader.load(context: context)
        if hasLoaded == false {
            hasLoaded = true
        }
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
        if isSettingsPresented, route.isSettingsScopeRoute {
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

    var isSettingsPresented: Bool {
        sheetRoute == .settings
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
             .duplicateTags,
             .year,
             .month,
             .item,
             .search:
            return false
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    MainNavigationView()
}
