//
//  SuggestionButtonGroup.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/1/24.
//

import SwiftData
import SwiftUI

struct SuggestionButtonGroup: View {
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
            HStack {
                if type == .category {
                    ForEach(categoryFacets) { facet in
                        Button(facet.displayName) {
                            Haptic.selectionChanged.impact()
                            input = facet.displayName
                        }
                        Divider()
                    }
                } else {
                    ForEach(suggestions) { suggestion in
                        Button(suggestion.name) {
                            Haptic.selectionChanged.impact()
                            input = suggestion.name
                        }
                        Divider()
                    }
                }
            }
        }
    }
}

private extension SuggestionButtonGroup {
    var categoryFacets: [CategoryFacet] {
        CategoryFacetService.filteredFacets(
            tags: categoryTags,
            items: items,
            query: input
        )
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    SuggestionButtonGroup(input: .constant("A"), type: .content)
}
