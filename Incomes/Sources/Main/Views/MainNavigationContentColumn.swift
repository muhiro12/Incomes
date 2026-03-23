import SwiftUI

struct MainNavigationContentColumn: View {
    @Environment(MainNavigationRouter.self)
    private var router

    let hasAnyYears: Bool
    let selectedYearTag: Tag?
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

    var body: some View {
        Group {
            if router.isSearchPresented {
                SearchListView(
                    selection: searchPredicateSelection,
                    searchText: searchText
                )
            } else if let selectedYearTag {
                HomeListView(
                    navigateToRoute: onNavigate
                )
                .environment(selectedYearTag)
            } else if hasAnyYears {
                ContentUnavailableView(
                    "Select a Year",
                    systemImage: "calendar",
                    description: Text("Choose a year to review monthly summaries and items.")
                )
            } else {
                ContentUnavailableView {
                    Label("Create Your First Item", systemImage: "square.and.pencil")
                } description: {
                    Text("Once you add an item, Incomes will organize it into a year timeline.")
                } actions: {
                    CreateItemButton()
                }
            }
        }
    }
}
