import SwiftUI

struct MainNavigationSearchContent: View {
    @Binding var searchPredicateSelection: ItemPredicate?
    @Binding var searchText: String
    @Binding var appliesInitialSearchText: Bool

    var body: some View {
        SearchListView(
            selection: $searchPredicateSelection,
            searchText: $searchText,
            appliesInitialSearchText: $appliesInitialSearchText
        )
    }
}
