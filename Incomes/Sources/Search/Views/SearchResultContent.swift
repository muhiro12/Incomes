import SwiftUI

struct SearchResultContent: View {
    let sections: [SearchResultOperations.Section]
    let firstItemID: Item.ID?

    var body: some View {
        if !sections.isEmpty {
            SearchResultList(
                sections: sections,
                firstItemID: firstItemID
            )
        } else {
            SearchResultUnavailableView()
        }
    }
}
