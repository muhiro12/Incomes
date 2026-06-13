import SwiftUI

struct SearchFilterSection: View {
    let selectedTarget: SearchTarget
    let contentTags: [Tag]
    let categoryFacets: [CategoryFacet]
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat
    let applyTagFilter: (Tag) -> Void
    let applyCategoryFilter: (CategoryFacet) -> Void

    var body: some View {
        switch selectedTarget {
        case .content:
            SearchContentFilterSection(
                tags: contentTags,
                applyFilter: applyTagFilter
            )
        case .category:
            SearchCategoryFilterSection(
                facets: categoryFacets,
                applyFilter: applyCategoryFilter
            )
        case .balance,
             .income,
             .outgo:
            SearchCurrencyFilterSection(
                minValue: $minValue,
                maxValue: $maxValue,
                controlSpacing: controlSpacing
            )
        }
    }
}
