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
        } content: { // swiftlint:disable:this closure_body_length
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
            },
            content: { sheetRoute in
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
        )
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

    init(incomingRoute: Binding<IncomesRoute?> = .constant(nil)) {
        _incomingRoute = incomingRoute
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
