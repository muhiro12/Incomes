import SwiftUI

struct MainNavigationSearchDetailContent: View {
    @Environment(MainNavigationRouter.self)
    private var router

    let predicate: ItemPredicate?

    var body: some View {
        if let predicate {
            SearchResultView(
                predicate: predicate,
                refineSearch: refineSearch
            )
        } else {
            MainNavigationSearchResultsContent()
        }
    }
}

private extension MainNavigationSearchDetailContent {
    func refineSearch() {
        router.selectSearchPredicate(nil)
    }
}
