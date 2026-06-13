import SwiftUI

struct CategoryRenamePreviewDetails: View {
    let trimmedDraftName: String
    let preview: TagRenamePreview

    var body: some View {
        CategoryRenamePreviewRow(
            title: "New name",
            value: preview.normalizedTargetName ?? trimmedDraftName
        )
        LabeledContent {
            Text(preview.affectedItemCount, format: .number)
                .foregroundStyle(.secondary)
        } label: {
            Text("Affected items")
        }
        if let validationError = preview.validationError {
            Text(validationError.renameErrorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
        } else if preview.isUnchanged {
            Text("This name is unchanged.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
