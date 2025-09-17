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

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var yearTag: Tag?
    @State private var tag: Tag?
    @State private var searchText = ""
    @State private var predicate: ItemPredicate?
    @State private var isSearchPresented = false
    @State private var isSettingsPresented = false
    @State private var isDebugPresented = false

    @State private var hasLoaded = false
    @State private var isIntroductionPresented = false

    var body: some View {
        NavigationSplitView {
            List(yearTags, selection: $yearTag) { yearTag in
                TagSummaryRow()
                    .environment(yearTag)
                    .tag(yearTag)
            }
            .navigationTitle("Incomes")
            .toolbar {
                if isDebugOn {
                    ToolbarItem {
                        Button("Debug", systemImage: "flask") {
                            isDebugPresented = true
                        }
                    }
                }
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
                } else if let yearTag {
                    HomeListView(selection: $tag)
                        .environment(yearTag)
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
                    CreateItemButton()
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsNavigationView()
            }
            .sheet(isPresented: $isDebugPresented) {
                DebugNavigationView()
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
            if !hasLoaded {
                hasLoaded = true
                isIntroductionPresented = (
                    try? ItemService.allItemsCount(context: context).isZero
                ) ?? false
            }

            yearTag = try? context.fetchFirst(
                .tags(
                    .nameIs(
                        Date.now.stringValueWithoutLocale(.yyyy),
                        type: .year
                    )
                )
            )
            tag = try? context.fetchFirst(
                .tags(
                    .nameIs(
                        Date.now.stringValueWithoutLocale(.yyyyMM),
                        type: .yearMonth
                    )
                )
            )
        }
    }
}

#Preview {
    IncomesPreview { _ in
        MainNavigationView()
    }
}
