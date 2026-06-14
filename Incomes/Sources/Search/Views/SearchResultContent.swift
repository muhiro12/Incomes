import SwiftUI

struct SearchResultContent: View {
    let sections: [SearchResultOperations.Section]
    let firstItemID: Item.ID?
    let refineSearch: (() -> Void)?

    var body: some View {
        if !sections.isEmpty {
            SearchResultList(
                sections: sections,
                firstItemID: firstItemID
            )
        } else {
            SearchResultUnavailableView(refineSearch: refineSearch)
        }
    }
}
