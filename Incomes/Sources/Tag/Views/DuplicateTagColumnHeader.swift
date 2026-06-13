import SwiftUI

struct DuplicateTagColumnHeader: View {
    let itemCount: Int
    let delete: () -> Void

    var body: some View {
        HStack {
            ItemCountStatusToolbarItem.localizedText(count: itemCount)
            Spacer()
            Button(role: .destructive, action: delete) {
                Label("Delete", systemImage: "trash")
            }
            .font(.caption)
            .textCase(nil)
            .accessibilityHint(Text("Delete this duplicate tag."))
        }
    }
}
