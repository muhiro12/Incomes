import SwiftData
import SwiftUI

struct WatchTagItemListView: View {
    private enum Layout {
        static let headerLineLimit = 2
        static let headerMinimumScaleFactor = 0.7
    }

    let tag: Tag

    var items: [Item] {
        TagOperations.items(for: tag)
    }

    var body: some View {
        List {
            Section {
                Text(tag.displayName)
                    .font(.headline)
                    .lineLimit(Layout.headerLineLimit)
                    .minimumScaleFactor(Layout.headerMinimumScaleFactor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if items.isNotEmpty {
                ForEach(items) { item in
                    WatchItemRow(item: item)
                }
            } else {
                Text("No items")
            }
        }
        .navigationTitle("Items")
    }
}
