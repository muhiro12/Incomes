import SwiftUI

struct MainNavigationSearchDetailContent: View {
    let predicate: ItemPredicate?

    var body: some View {
        if let predicate {
            SearchResultView(predicate: predicate)
        } else {
            MainNavigationSearchResultsContent()
        }
    }
}
