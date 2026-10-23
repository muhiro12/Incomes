import SwiftUI

struct SearchResultList: View {
    @Environment(\.navigationItemSelection)
    private var navigationItemSelection

    let sections: [SearchResultOperations.Section]
    let firstItemID: Item.ID?

    var body: some View {
        List(selection: navigationItemSelection) {
            ForEach(sections, id: \.month) { section in
                SearchResultSection(
                    section: section,
                    firstItemID: firstItemID
                )
            }
        }
    }
}
