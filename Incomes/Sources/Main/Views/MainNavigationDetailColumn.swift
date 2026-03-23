import SwiftUI

struct MainNavigationDetailColumn: View {
    @Environment(MainNavigationRouter.self)
    private var router

    var body: some View {
        Group {
            if router.isSearchPresented {
                if let predicate = router.predicate {
                    SearchResultView(predicate: predicate)
                } else {
                    ContentUnavailableView(
                        "Search Results",
                        systemImage: "magnifyingglass",
                        description: Text("Choose a filter or enter an amount range to see matching items.")
                    )
                }
            } else if let selectedTag = router.selectedTag {
                ItemListGroup()
                    .environment(selectedTag)
            } else {
                ContentUnavailableView(
                    "Select a Month",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Pick a month or summary from the middle column to inspect item details.")
                )
            }
        }
    }
}
