import SwiftUI

struct SearchListContent: View {
    @Binding var predicate: ItemPredicate?
    @Binding var selectedTarget: SearchTarget
    let contentTags: [Tag]
    let categoryFacets: [CategoryFacet]
    @Binding var minValue: String
    @Binding var maxValue: String
    let isMinimumValueValid: Bool
    let isMaximumValueValid: Bool
    let controlSpacing: CGFloat
    let currencyPredicate: ItemPredicate?
    let applyTagFilter: (Tag) -> Void
    let applyCategoryFilter: (CategoryFacet) -> Void
    let applyCurrencyFilter: () -> Void

    var body: some View {
        List(selection: $predicate) {
            SearchTargetSection(selectedTarget: $selectedTarget)
            SearchFilterSection(
                selectedTarget: selectedTarget,
                contentTags: contentTags,
                categoryFacets: categoryFacets,
                minValue: $minValue,
                maxValue: $maxValue,
                isMinimumValueValid: isMinimumValueValid,
                isMaximumValueValid: isMaximumValueValid,
                controlSpacing: controlSpacing,
                applySearch: applyCurrencyFilter,
                applyTagFilter: applyTagFilter,
                applyCategoryFilter: applyCategoryFilter
            )
            SearchCurrencyActionSection(
                isVisible: selectedTarget.isForCurrency,
                isEnabled: isMinimumValueValid && isMaximumValueValid,
                predicate: currencyPredicate
            )
        }
    }
}
