import SwiftUI

struct CategoryRenamePreviewRow: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        LabeledContent {
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        } label: {
            Text(title)
        }
    }
}
