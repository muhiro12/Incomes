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

    @State private var yearTagID: Tag.ID?
    @State private var tag: Tag?
    @State private var searchText = ""
    @State private var predicate: ItemPredicate?
    @State private var isSearchPresented = false
    @State private var isSettingsPresented = false
    @State private var isYearlyDuplicationPresented = false
    @State private var isYearDeleteDialogPresented = false
    @State private var willDeleteItems: [Item] = []
    @State private var willDeleteTags: [Tag] = []

    @State private var hasLoaded = false
    @State private var isIntroductionPresented = false
    @State private var pendingRoute: IncomesRoute?

    init(incomingRoute: Binding<IncomesRoute?> = .constant(nil)) {
        _incomingRoute = incomingRoute
    }

    private var selectedYearTag: Tag? {
        guard let yearTagID else {
            return nil
        }
        return yearTags.first { tag in
            tag.persistentModelID == yearTagID
        }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $yearTagID) {
                ForEach(yearTags, id: \.persistentModelID) { yearTag in
                    TagSummaryRow()
                        .environment(yearTag)
                        .tag(yearTag.persistentModelID)
                }
                .onDelete { indices in
                    Haptic.warning.impact()
                    isYearDeleteDialogPresented = true
                    willDeleteTags = indices.compactMap { index in
                        guard yearTags.indices.contains(index) else {
                            return nil
                        }
                        return yearTags[index]
                    }
                    willDeleteItems = TagService.resolveItemsForDeletion(
                        from: yearTags,
                        indices: indices
                    )
                }
                YearlyDuplicationPromoSection(
                    context: context,
                    yearTags: yearTags
                ) {
                    isYearlyDuplicationPresented = true
                }
            }
            .confirmationDialog(
                Text("Delete"),
                isPresented: $isYearDeleteDialogPresented
            ) {
                Button(role: .destructive) {
                    do {
                        try ItemService.delete(
                            context: context,
                            items: willDeleteItems
                        )
                        if let selectedYearTag,
                           willDeleteTags.contains(where: { tag in
                            tag.name == selectedYearTag.name && tag.typeID == selectedYearTag.typeID
                           }) {
                            yearTagID = nil
                        }
                        willDeleteItems = []
                        willDeleteTags = []
                        Haptic.success.impact()
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                } label: {
                    Text("Delete")
                }
                Button(role: .cancel) {
                    willDeleteItems = []
                    willDeleteTags = []
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
                        isSettingsPresented = true
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
                if isSearchPresented {
                    SearchListView(
                        selection: $predicate,
                        searchText: $searchText
                    )
                } else if let selectedYearTag {
                    HomeListView(selection: $tag)
                        .environment(selectedYearTag)
                }
            }
            .searchable(text: $searchText, isPresented: $isSearchPresented)
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
            .sheet(isPresented: $isSettingsPresented) {
                SettingsNavigationView()
            }
            .sheet(isPresented: $isYearlyDuplicationPresented) {
                NavigationStack {
                    YearlyDuplicationView()
                }
            }
        } detail: {
            if isSearchPresented {
                SearchResultView(predicate: predicate ?? .none)
            } else if let tag {
                ItemListGroup()
                    .environment(tag)
            }
        }
        .sheet(isPresented: $isIntroductionPresented) {
            IntroductionNavigationView()
        }
        .onChange(of: incomingRoute) {
            handleIncomingRouteIfNeeded()
        }
        .task {
            do {
                let state = try MainNavigationStateLoader.load(
                    context: context
                )
                if !hasLoaded {
                    hasLoaded = true
                    isIntroductionPresented = state.isIntroductionPresented
                }
                yearTagID = state.yearTag?.persistentModelID
                tag = state.yearMonthTag
            } catch {
                assertionFailure(error.localizedDescription)
            }

            handleIncomingRouteIfNeeded()
            applyPendingRouteIfNeeded()

            await PhoneWatchBridge.shared.activate(modelContext: context)
        }
    }
}

private extension MainNavigationView {
    func handleIncomingRouteIfNeeded() {
        guard let route = incomingRoute else {
            return
        }
        if hasLoaded {
            apply(route: route)
        } else {
            pendingRoute = route
        }
        incomingRoute = nil
    }

    func applyPendingRouteIfNeeded() {
        guard hasLoaded,
              let pendingRoute else {
            return
        }
        apply(route: pendingRoute)
        self.pendingRoute = nil
    }

    func apply(route: IncomesRoute) {
        do {
            switch route {
            case .home:
                let state = try MainNavigationStateLoader.load(
                    context: context
                )
                yearTagID = state.yearTag?.persistentModelID
                tag = state.yearMonthTag
                isSearchPresented = false
                searchText = .empty
                predicate = nil
            case .settings:
                isSettingsPresented = true
            case .year(let year):
                let yearTagName = String(format: "%04d", year)
                let yearTag = try TagService.getByName(
                    context: context,
                    name: yearTagName,
                    type: .year
                )
                yearTagID = yearTag?.persistentModelID
                tag = nil
                isSearchPresented = false
                searchText = .empty
                predicate = nil
            case .month(let year, let month):
                let yearTagName = String(format: "%04d", year)
                let yearMonthTagName = String(format: "%04d%02d", year, month)
                let yearTag = try TagService.getByName(
                    context: context,
                    name: yearTagName,
                    type: .year
                )
                let yearMonthTag = try TagService.getByName(
                    context: context,
                    name: yearMonthTagName,
                    type: .yearMonth
                )
                yearTagID = yearTag?.persistentModelID
                tag = yearMonthTag
                isSearchPresented = false
                searchText = .empty
                predicate = nil
            case .search(let query):
                isSearchPresented = true
                searchText = query ?? .empty
                predicate = nil
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    MainNavigationView()
}
