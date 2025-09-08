//
//  AppNavigationView.swift
//  Incomes
//
//  Created by Codex on 2025/09/09.
//

import SwiftUI

struct AppNavigationView: View {
    @State private var mainFeature = MainFeature.home

    @State private var homeTag: Tag?
    @State private var contentTag: Tag?
    @State private var categoryTag: Tag?
    @State private var searchPredicate: ItemPredicate?

    var body: some View {
        NavigationSplitView {
            List(selection: .constant(mainFeature)) {
                ForEach(MainFeature.allCases) { feature in
                    Button {
                        Haptic.selectionChanged.impact()
                        withAnimation {
                            mainFeature = feature
                        }
                    } label: {
                        feature.label
                            .fontWeight(feature == mainFeature ? .semibold : .regular)
                    }
                }
            }
            .navigationTitle(Text("Menu"))
        } content: {
            switch mainFeature {
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
            switch mainFeature {
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
    }
}

#Preview {
    IncomesPreview { _ in
        AppNavigationView()
    }
}
