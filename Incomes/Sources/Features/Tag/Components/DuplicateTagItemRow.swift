import SwiftData
import SwiftUI

struct DuplicateTagItemRow {
    @Environment(Item.self)
    private var item
}

extension DuplicateTagItemRow: View {
    var body: some View {
        HStack {
            Text(item.content)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .itemEntityIdentifier(item)
        .contextMenu {
            ItemContextMenuActions()
        } preview: {
            ItemPreviewNavigationView()
                .environment(item)
        }
    }
}
