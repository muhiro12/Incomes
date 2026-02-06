//
//  MainNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftData
import SwiftUI

struct MainNavigationView: View {
    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.year), order: .reverse))
    private var yearTags: [Tag]

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
                StatusToolbarItem("Today: \(Date.now.stableStringValue(.yyyyMMMd))")
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
                StatusToolbarItem("Today: \(Date.now.stableStringValue(.yyyyMMMd))")
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

            await PhoneWatchBridge.shared.activate(modelContext: context)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    MainNavigationView()
}
