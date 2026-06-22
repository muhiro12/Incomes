import SwiftUI

struct SearchInitialTextModifier: ViewModifier {
    let selectedTarget: SearchTarget
    let contentTags: [Tag]
    @Binding var predicate: ItemPredicate?
    @Binding var searchText: String
    @Binding var appliesInitialSearchText: Bool
    let applyTagFilter: (Tag) -> Void

    func body(content: Content) -> some View {
        content
            .task {
                applyInitialSearchTextIfNeeded()
            }
            .onChange(of: contentTags.count) {
                applyInitialSearchTextIfNeeded()
            }
    }
}

private extension SearchInitialTextModifier {
    func applyInitialSearchTextIfNeeded() {
        guard appliesInitialSearchText else {
            return
        }

        guard !searchText.isEmpty else {
            appliesInitialSearchText = false
            return
        }

        guard predicate == nil else {
            appliesInitialSearchText = false
            return
        }

        let matchingTags = selectedTarget.filteredTags(
            contentTags,
            searchText: searchText
        )
        guard matchingTags.count == 1,
              let matchingTag = matchingTags.first else {
            return
        }

        appliesInitialSearchText = false
        applyTagFilter(matchingTag)
    }
}
