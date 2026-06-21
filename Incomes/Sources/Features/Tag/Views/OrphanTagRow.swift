import SwiftUI

struct OrphanTagRow: View {
    let tag: Tag

    @Binding var selectedTagID: Tag.ID?

    var body: some View {
        HStack {
            Text(tag.displayName)
            Spacer()
            Text(0, format: .number)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Open", systemImage: "arrow.right.circle") {
                selectedTagID = tag.persistentModelID
            }
            CopyTextContextMenuButton(
                "Copy Name",
                text: tag.displayName
            )
        }
        .tag(tag.persistentModelID)
    }
}
