import SwiftUI

struct SearchResultList: View {
    let sections: [SearchResultOperations.Section]
    let firstItemID: Item.ID?

    var body: some View {
        List {
            ForEach(sections, id: \.month) { section in
                SearchResultSection(
                    section: section,
                    firstItemID: firstItemID
                )
            }
        }
    }
}
