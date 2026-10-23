import SwiftUI

struct MainNavigationSidebarColumn: View {
    @Environment(MainNavigationRouter.self)
    private var router

    let yearTags: [Tag]
    let selectedYearTag: Tag?
    let tagSelection: Binding<Tag.ID?>
    let onNavigate: (IncomesRoute) -> Void

    var body: some View {
        @Bindable var router = router

        Group {
            if router.isSearchActive {
                MainNavigationSearchContent(
                    searchPredicateSelection: Binding(
                        get: {
                            router.predicate
                        },
                        set: { predicate in
                            router.selectSearchPredicate(predicate)
                        }
                    ),
                    searchText: $router.searchText,
                    appliesInitialSearchText: $router.appliesInitialSearchText
                ) { _ in
                    router.dismissSearch()
                }
            } else {
                MainNavigationSidebarView(
                    yearTags: yearTags,
                    selectedYearTag: selectedYearTag,
                    tagSelection: tagSelection,
                    onNavigate: onNavigate
                )
                .environment(\.navigationTagSelection, tagSelection)
            }
        }
    }
}
