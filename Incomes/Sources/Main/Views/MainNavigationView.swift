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

    @Binding private var incomingRouteURL: URL?

    @StateObject private var router: MainNavigationRouter = .init()

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
        NavigationSplitView(preferredCompactColumn: $router.preferredCompactColumn) { // swiftlint:disable:this closure_body_length line_length
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
                            enqueueNavigation(to: .yearlyDuplication)
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
        } content: { // swiftlint:disable:this closure_body_length
            Group {
                if router.isSearchPresented {
                    SearchListView(
                        selection: searchPredicateSelection,
                        searchText: $router.searchText
                    )
                } else if let selectedYearTag {
                    HomeListView { route in
                        enqueueNavigation(to: route)
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
                Task {
                    applyPendingRouteAfterSettingsDismissalIfNeeded()
                }
            },
            content: { sheetRoute in
                switch sheetRoute {
                case .settings:
                    SettingsNavigationView(
                        incomingDestination: $router.settingsDestination
                    ) { route in
                        Task {
                            await navigateFromSettings(to: route)
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
        )
        .fullScreenCover(item: $router.fullScreenRoute) { fullScreenRoute in
            switch fullScreenRoute {
            case .duplicateTags:
                DuplicateTagNavigationView()
            }
        }
        .onChange(of: incomingRouteURL) {
            Task {
                await handleIncomingRouteURL()
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
            await loadState()

            tipController.refreshHasAnyItems(!yearTags.isEmpty)

            await handleIncomingRouteURL()
            await applyPendingRouteIfNeeded()

            await PhoneWatchBridge.shared.activate(modelContext: context)
        }
    }

    init(incomingRouteURL: Binding<URL?> = .constant(nil)) {
        _incomingRouteURL = incomingRouteURL
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
              1...9_999 ~= year else { // swiftlint:disable:this no_magic_numbers
            router.selectYearTagID(yearTagID)
            return
        }
        enqueueNavigation(to: .year(year))
    }

    func enqueueNavigation(to route: IncomesRoute) {
        Task {
            await navigate(to: route)
        }
    }

    func loadState() async {
        do {
            try await router.loadState(
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func navigate(to route: IncomesRoute) async {
        do {
            try await router.navigate(
                to: route,
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func navigateFromSettings(to route: IncomesRoute) async {
        do {
            try await router.navigateFromSettings(
                to: route,
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func handleIncomingRouteURL() async {
        guard let url = incomingRouteURL else {
            return
        }
        incomingRouteURL = nil
        do {
            try await router.handleIncomingURL(
                url,
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func applyPendingRouteIfNeeded() async {
        do {
            try await router.applyPendingRouteIfNeeded(
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func applyPendingRouteAfterSettingsDismissalIfNeeded() {
        do {
            try router.applyPendingRouteAfterSettingsDismissalIfNeeded(
                context: context
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
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

extension IncomesRoute {
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
