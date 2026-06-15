import SwiftUI

struct CategoryRenamePreviewFailureDetails: View {
    let trimmedDraftName: String
    let error: TagRenameError

    var body: some View {
        CategoryRenamePreviewRow(
            title: "New name",
            value: trimmedDraftName
        )
        Label {
            Text(error.renameErrorMessage)
        } icon: {
            Image(systemName: "exclamationmark.circle.fill")
        }
        .font(.footnote)
        .foregroundStyle(.red)
        .accessibilityLabel(Text("Error: \(error.renameErrorMessage)"))
    }
}
