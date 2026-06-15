import SwiftUI

struct SearchContentFilterSection: View {
    let tags: [Tag]
    let applyFilter: (Tag) -> Void

    var body: some View {
        Section("Filter") {
            if tags.isEmpty {
                SearchEmptyStateContent()
            } else {
                ForEach(tags) { tag in
                    SearchTagFilterRow(
                        tag: tag,
                        applyFilter: applyFilter
                    )
                }
            }
        }
    }
}
