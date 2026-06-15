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
        SearchListContent(
            selectedTarget: $selectedTarget,
            contentTags: filteredContentTags,
            categoryFacets: categoryFacets,
            minValue: $minValue,
            maxValue: $maxValue,
            isMinimumValueValid: minValue.isEmptyOrDecimal,
            isMaximumValueValid: maxValue.isEmptyOrDecimal,
            controlSpacing: designMetrics.spacing.control,
            applyTagFilter: applyTagFilter,
            applyCategoryFilter: applyCategoryFilter,
            applyCurrencyFilter: applyCurrencyFilter
        )
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Search")
        .modifier(
            SearchInitialTextModifier(
                selectedTarget: selectedTarget,
                contentTags: contents,
                predicate: $predicate,
                searchText: $searchText,
                appliesInitialSearchText: $appliesInitialSearchText,
                applyTagFilter: applyTagFilter
            )
        )
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

    var isCurrencyFilterValid: Bool {
        minValue.isEmptyOrDecimal && maxValue.isEmptyOrDecimal
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
        guard isCurrencyFilterValid else {
            return
        }

        guard let newPredicate = selectedTarget.predicate(
            minimumText: minValue,
            maximumText: maxValue
        ) else {
            return
        }

        tipController.donateDidApplySearch()
        predicate = newPredicate
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
