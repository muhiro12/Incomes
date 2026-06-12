import SwiftUI

struct SearchTagFilterRow: View {
    let tag: Tag
    let applyFilter: (Tag) -> Void

    var body: some View {
        Button {
            applyFilter(tag)
        } label: {
            HStack {
                Text(tag.displayName)
                Spacer()
                Text((tag.items ?? []).count.description)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .contextMenu {
            Button(
                "Apply Filter",
                systemImage: "line.3.horizontal.decrease.circle"
            ) {
                applyFilter(tag)
            }
            CopyTextContextMenuButton(
                "Copy Name",
                text: tag.displayName
            )
        }
    }
}
