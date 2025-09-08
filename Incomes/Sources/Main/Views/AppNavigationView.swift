//
//  AppNavigationView.swift
//  Incomes
//
//  Created by Codex on 2025/09/09.
//

import SwiftData
import SwiftUI

struct AppNavigationView: View {
    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.yearMonth)))
    private var yearMonthTags: [Tag]
    @Query(.tags(.typeIs(.content)))
    private var contentTags: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categoryTags: [Tag]

    @State private var mainFeature = MainFeature.home

    @State private var homeSelectedYear: Tag?
    @State private var homeSelectedDetailTag: Tag?
    @State private var contentTag: Tag?
    @State private var categoryTag: Tag?
    @State private var searchPredicate: ItemPredicate?

    var body: some View {
        NavigationSplitView {
            List {
                Section("Home") {
                    ForEach(sortedYearMonthTags) { tag in
                        Button {
                            Haptic.selectionChanged.impact()
                            mainFeature = .home
                            homeSelectedYear = fetchYearTag(from: tag)
                            homeSelectedDetailTag = tag
                        } label: {
                            Label(tag.displayName, systemImage: "calendar")
                        }
                    }
                }
                Section("Content") {
                    Button {
                        Haptic.selectionChanged.impact()
                        mainFeature = .content
                    } label: {
                        Label("Content", systemImage: "doc.text")
                    }
                }
                Section("Category") {
                    Button {
                        Haptic.selectionChanged.impact()
                        mainFeature = .category
                    } label: {
                        Label("Category", systemImage: "tag")
                    }
                }
                Section("Search") {
                    Button {
                        Haptic.selectionChanged.impact()
                        mainFeature = .search
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
            }
            .navigationTitle(Text("Menu"))
        } content: {
            switch mainFeature {
            case .home:
                if let homeSelectedYear {
                    HomeYearListView(yearTag: homeSelectedYear)
                } else {
                    Text("Select a month")
                        .foregroundStyle(.secondary)
                }
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
                if let detailTag = homeSelectedDetailTag {
                    ItemListGroup()
                        .environment(detailTag)
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

private extension AppNavigationView {
    var sortedYearMonthTags: [Tag] {
        yearMonthTags.sorted { $0.name > $1.name }
    }

    func fetchYearTag(from yearMonth: Tag) -> Tag? {
        let yearString = String(yearMonth.name.prefix(4))
        return try? context.fetchFirst(
            .tags(
                .nameIs(yearString, type: .year)
            )
        )
    }
}

#Preview {
    IncomesPreview { _ in
        AppNavigationView()
    }
}
