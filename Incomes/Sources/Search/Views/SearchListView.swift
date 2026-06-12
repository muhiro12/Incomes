//
//  SearchListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//

import MHDesign
import SwiftData
import SwiftUI

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
    @State private var minValue = ""
    @State private var maxValue = ""

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
        List {
            SearchTargetSection(selectedTarget: $selectedTarget)
            SearchFilterSection(
                selectedTarget: selectedTarget,
                contentTags: filteredContentTags,
                categoryFacets: categoryFacets,
                minValue: $minValue,
                maxValue: $maxValue,
                controlSpacing: designMetrics.spacing.control,
                applyTagFilter: applyTagFilter,
                applyCategoryFilter: applyCategoryFilter
            )
            SearchCurrencyActionSection(
                isVisible: selectedTarget.isForCurrency,
                applySearch: applyCurrencyFilter
            )
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
    var filteredContentTags: [Tag] {
        selectedTarget.filteredTags(
            contents,
            searchText: searchText
        )
    }

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
            return filteredContentTags.isEmpty
        case .category:
            return categoryFacets.isEmpty
        case .balance,
             .income,
             .outgo:
            return false
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

    func applyCurrencyFilter() {
        guard let newPredicate = selectedTarget.predicate(
            minimumText: minValue,
            maximumText: maxValue
        ) else {
            return
        }

        tipController.donateDidApplySearch()
        predicate = newPredicate
    }

    func applyInitialSearchTextIfNeeded() {
        guard appliesInitialSearchText else {
            return
        }

        guard !searchText.isEmpty else {
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
            searchText: .constant("")
        )
    }
}
