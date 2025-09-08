//
//  AppNavigationView.swift
//  Incomes
//
//  Created by Codex on 2025/09/09.
//

import SwiftUI

struct AppNavigationView: View {
    @State private var mainTab = MainTab.home

    @State private var homeTag: Tag?
    @State private var contentTag: Tag?
    @State private var categoryTag: Tag?
    @State private var searchPredicate: ItemPredicate?

    var body: some View {
        NavigationSplitView {
            List(selection: .constant(mainTab)) {
                ForEach(MainTab.allCases) { tab in
                    Button {
                        Haptic.selectionChanged.impact()
                        withAnimation {
                            mainTab = tab
                        }
                    } label: {
                        tab.label
                            .fontWeight(tab == mainTab ? .semibold : .regular)
                    }
                }
            }
            .navigationTitle(Text("Menu"))
        } content: {
            switch mainTab {
            case .home:
                HomeListView(selection: $homeTag)
            case .content:
                TagListView(tagType: .content, selection: $contentTag)
            case .category:
                TagListView(tagType: .category, selection: $categoryTag)
            case .search:
                SearchListView(selection: $searchPredicate)
            }
        } detail: {
            switch mainTab {
            case .home:
                if let homeTag {
                    ItemListGroup()
                        .environment(homeTag)
                }
            case .content:
                if let contentTag {
                    ItemListGroup()
                        .environment(contentTag)
                }
            case .category:
                if let categoryTag {
                    ItemListGroup()
                        .environment(categoryTag)
                }
            case .search:
                SearchResultView(predicate: searchPredicate ?? .none)
            }
        }
        .environment(\.mainTab, $mainTab)
    }
}

#Preview {
    IncomesPreview { _ in
        AppNavigationView()
    }
}
