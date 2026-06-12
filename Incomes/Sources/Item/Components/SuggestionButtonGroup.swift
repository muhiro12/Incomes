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
    @Query(.tags(.typeIs(.category)))
    private var categoryTags: [Tag]
    @Query(.items(.all))
    private var items: [Item]

    @Binding private var input: String
    private let type: TagType

    init(input: Binding<String>, type: TagType) { // swiftlint:disable:this type_contents_order
        _input = input
        self.type = type
        _suggestions = Query(
            .tags(.nameContains(input.wrappedValue, type: type))
        )
    }

    var body: some View {
        ScrollView(.horizontal) {
            IncomesLiquidGlassControlGroup(spacing: Constants.controlSpacing) {
                suggestionButtons
            }
        }
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

    @ViewBuilder var suggestionButtons: some View {
        HStack(spacing: Constants.controlSpacing) {
            if type == .category {
                ForEach(categoryFacets) { facet in
                    suggestionButton(title: facet.displayName) {
                        input = facet.displayName
                    }
                }
            } else {
                ForEach(suggestions) { suggestion in
                    suggestionButton(title: suggestion.name) {
                        input = suggestion.name
                    }
                }
            }
        }
    }

    func suggestionButton(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(title) {
            Haptic.selectionChanged.impact()
            action()
        }
        .incomesSecondaryControlStyle()
        .controlSize(.small)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    SuggestionButtonGroup(input: .constant("A"), type: .content)
}
