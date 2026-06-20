import SwiftUI

struct MainNavigationSearchContent: View {
    private enum Constants {
        static let buttonHorizontalPadding: CGFloat = 4
        static let buttonVerticalPadding: CGFloat = 8
        static let headerBottomPadding: CGFloat = 12
        static let headerTopPadding: CGFloat = 8
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @Binding var searchPredicateSelection: ItemPredicate?
    @Binding var searchText: String
    @Binding var appliesInitialSearchText: Bool

    let dismissSearch: (Bool) -> Void

    var body: some View {
        SearchListView(
            selection: $searchPredicateSelection,
            searchText: $searchText,
            appliesInitialSearchText: $appliesInitialSearchText
        )
        .safeAreaInset(edge: .top, spacing: .zero) {
            if horizontalSizeClass == .compact {
                searchHeader
            }
        }
    }
}

private extension MainNavigationSearchContent {
    var searchHeader: some View {
        HStack {
            Text("Search")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button {
                dismissSearch(horizontalSizeClass != .regular)
            } label: {
                Text("Cancel")
                    .padding(.vertical, Constants.buttonVerticalPadding)
                    .padding(.horizontal, Constants.buttonHorizontalPadding)
            }
            .accessibilityLabel(Text("Cancel Search"))
            .accessibilityHint(Text("Returns to the year list."))
            .accessibilityAddTraits(.isButton)
        }
        .padding(.horizontal)
        .padding(.top, Constants.headerTopPadding)
        .padding(.bottom, Constants.headerBottomPadding)
        .background(.bar)
    }
}
