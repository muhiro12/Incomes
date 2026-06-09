//
//  SearchListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//

import MHDesign
import SwiftData
import SwiftUI
import TipKit

struct SearchListView: View {
    @Environment(IncomesTipController.self)
    private var tipController
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Query(.items(.all))
    private var items: [Item]
    @Query(.tags(.typeIs(.content)))
    private var contents: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categories: [Tag]

    @Binding private var predicate: ItemPredicate?
    @Binding private var searchText: String
    @Binding private var appliesInitialSearchText: Bool

    @State private var selectedTarget = SearchTarget.content
    @State private var minValue = String.empty
    @State private var maxValue = String.empty

    private let searchFiltersTip = SearchFiltersTip()

    init( // swiftlint:disable:this type_contents_order
        selection: Binding<ItemPredicate?>,
        searchText: Binding<String>,
        appliesInitialSearchText: Binding<Bool> = .constant(false)
    ) {
        _predicate = selection
        _searchText = searchText
        _appliesInitialSearchText = appliesInitialSearchText
    }

    var body: some View {
        List { // swiftlint:disable:this closure_body_length
            Section("Target") {
                Picker("Target", selection: $selectedTarget) {
                    ForEach(SearchTarget.allCases, id: \.self) { target in
                        Text(target.value)
                            .tag(target)
                    }
                }
                .pickerStyle(.menu)
                .popoverTip(searchFiltersTip, arrowEdge: .top)
            }
            Section("Filter") {
                switch selectedTarget {
                case .content:
                    buildTagRows(tags: contents)
                case .category:
                    buildCategoryRows(facets: categoryFacets)
                case .balance,
                     .income,
                     .outgo:
                    buildCurrencyRows()
                }
            }
            if selectedTarget.isForCurrency {
                Section {
                    Button("Search", systemImage: "magnifyingglass") {
                        if let newPredicate = selectedTarget.predicate(
                            minimumText: minValue,
                            maximumText: maxValue
                        ) {
                            tipController.donateDidApplySearch()
                            predicate = newPredicate
                        }
                    }
                }
            }
        }
        .overlay {
            if isShowingEmptyState {
                ContentUnavailableView(
                    "No Matches",
                    systemImage: "magnifyingglass",
                    description: Text("Try another keyword or switch the search target.")
                )
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Search")
        .task {
            applyInitialSearchTextIfNeeded()
        }
        .onChange(of: contents.count) {
            applyInitialSearchTextIfNeeded()
        }
    }
}

private extension SearchListView {
    var categoryFacets: [CategoryFacet] {
        CategoryFacetOperations.filteredFacets(
            tags: categories,
            items: items,
            query: searchText
        )
    }

    var isShowingEmptyState: Bool {
        switch selectedTarget {
        case .content:
            return selectedTarget.filteredTags(
                contents,
                searchText: searchText
            ).isEmpty
        case .category:
            return categoryFacets.isEmpty
        case .balance,
             .income,
             .outgo:
            return false
        }
    }

    func buildTagRows(tags: [Tag]) -> some View {
        ForEach(
            selectedTarget.filteredTags(tags, searchText: searchText)
        ) { tag in
            Button {
                applyTagFilter(tag)
            } label: {
                HStack {
                    Text(tag.displayName)
                    Spacer()
                    Text(tag.items.orEmpty.count.description)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .contextMenu {
                Button(
                    "Apply Filter",
                    systemImage: "line.3.horizontal.decrease.circle"
                ) {
                    applyTagFilter(tag)
                }
                CopyTextContextMenuButton(
                    "Copy Name",
                    text: tag.displayName
                )
            }
        }
    }

    func buildCategoryRows(facets: [CategoryFacet]) -> some View {
        ForEach(facets) { facet in
            Button {
                applyCategoryFilter(facet)
            } label: {
                HStack {
                    Text(facet.displayName)
                    Spacer()
                    Text(facet.count.description)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .contextMenu {
                Button(
                    "Apply Filter",
                    systemImage: "line.3.horizontal.decrease.circle"
                ) {
                    applyCategoryFilter(facet)
                }
                CopyTextContextMenuButton(
                    "Copy Name",
                    text: facet.displayName
                )
            }
        }
    }

    func buildCurrencyRows() -> some View {
        HStack(spacing: designMetrics.spacing.control) {
            TextField("Min", text: $minValue)
                .keyboardType(.numbersAndPunctuation)
            Text("~")
            TextField("Max", text: $maxValue)
                .keyboardType(.numbersAndPunctuation)
        }
    }

    func applyTagFilter(_ tag: Tag) {
        tipController.donateDidApplySearch()
        predicate = .tagIs(tag)
    }

    func applyCategoryFilter(_ facet: CategoryFacet) {
        tipController.donateDidApplySearch()
        predicate = .idsAre(facet.itemIDs)
    }

    func applyInitialSearchTextIfNeeded() {
        guard appliesInitialSearchText else {
            return
        }

        guard searchText.isNotEmpty else {
            appliesInitialSearchText = false
            return
        }

        guard predicate == nil else {
            appliesInitialSearchText = false
            return
        }

        let matchingTags = selectedTarget.filteredTags(
            contents,
            searchText: searchText
        )
        guard matchingTags.count == 1,
              let matchingTag = matchingTags.first else {
            return
        }

        appliesInitialSearchText = false
        applyTagFilter(matchingTag)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        SearchListView(
            selection: .constant(.all),
            searchText: .constant(.empty)
        )
    }
}
