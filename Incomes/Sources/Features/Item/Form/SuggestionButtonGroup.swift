//
//  SuggestionButtonGroup.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/1/24.
//

import SwiftData
import SwiftUI

struct SuggestionButtonGroup: View {
    private enum Constants {
        static let controlSpacing: CGFloat = 8
    }

    @Query private var suggestions: [Tag]
    @Query private var categoryTags: [Tag]
    @Query private var items: [Item]

    @Binding private var input: String
    private let type: TagType

    init(input: Binding<String>, type: TagType, ledgerIdentifier: LedgerIdentifier = .default) {
        _categoryTags = .init(.tags(.typeIs(.category)))
        _items = .init(.items(.all, ledgerIdentifier: ledgerIdentifier))
        _input = input
        self.type = type
        _suggestions = Query(
            .tags(.nameContains(input.wrappedValue, type: type))
        )
    }
}

extension SuggestionButtonGroup {
    @ViewBuilder var body: some View {
        ScrollView(.horizontal) {
            IncomesLiquidGlassControlGroup(spacing: Constants.controlSpacing) {
                SuggestionButtonContent(
                    type: type,
                    suggestions: suggestions,
                    categoryFacets: categoryFacets,
                    input: $input,
                    controlSpacing: Constants.controlSpacing
                )
            }
        }
        .contentMargins(.horizontal, Constants.controlSpacing, for: .scrollContent)
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
    }
}

private extension SuggestionButtonGroup {
    var categoryFacets: [CategoryFacet] {
        CategoryFacetOperations.filteredFacets(
            tags: categoryTags,
            items: items,
            query: input
        )
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    SuggestionButtonGroup(input: .constant("A"), type: .content)
}
