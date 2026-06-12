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
        Section("Filter") {
            switch selectedTarget {
            case .content:
                ForEach(contentTags) { tag in
                    SearchTagFilterRow(
                        tag: tag,
                        applyFilter: applyTagFilter
                    )
                }
            case .category:
                ForEach(categoryFacets) { facet in
                    SearchCategoryFilterRow(
                        facet: facet,
                        applyFilter: applyCategoryFilter
                    )
                }
            case .balance,
                 .income,
                 .outgo:
                SearchCurrencyFilterFields(
                    minValue: $minValue,
                    maxValue: $maxValue,
                    controlSpacing: controlSpacing
                )
            }
        }
    }
}
