import SwiftUI

struct MainNavigationContentColumn: View {
    @Environment(Tag.self)
    private var selectedYearTag: Tag?
    @Environment(MainNavigationRouter.self)
    private var router

    let hasAnyYears: Bool
    let onNavigate: (IncomesRoute) -> Void

    private var searchPredicateSelection: Binding<ItemPredicate?> {
        .init(
            get: {
                router.predicate
            },
            set: { predicate in
                router.selectSearchPredicate(predicate)
            }
        )
    }

    private var searchText: Binding<String> {
        .init(
            get: {
                router.searchText
            },
            set: { value in
                router.searchText = value
            }
        )
    }

    private var appliesInitialSearchText: Binding<Bool> {
        .init(
            get: {
                router.appliesInitialSearchText
            },
            set: { value in
                router.appliesInitialSearchText = value
            }
        )
    }

    var body: some View {
        Group {
            if router.isSearchPresented {
                MainNavigationSearchContent(
                    searchPredicateSelection: searchPredicateSelection,
                    searchText: searchText,
                    appliesInitialSearchText: appliesInitialSearchText
                ) { isCompact in
                    router.dismissSearch()
                    router.restoreSidebarAfterSearchDismissalIfNeeded(
                        isCompact: isCompact
                    )
                }
            } else if selectedYearTag != nil {
                HomeListView(navigateToRoute: onNavigate)
            } else if hasAnyYears {
                MainNavigationSelectYearContent()
            } else {
                MainNavigationEmptyYearsContent()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
