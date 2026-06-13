import SwiftUI

struct CategoryRenamePreviewSection: View {
    let currentName: String
    let trimmedDraftName: String
    let previewResult: Result<TagRenamePreview, TagRenameError>

    var body: some View {
        Section("Preview") {
            CategoryRenamePreviewRow(
                title: "Current name",
                value: currentName
            )

            switch previewResult {
            case .success(let preview):
                previewDetails(
                    for: preview
                )
            case .failure(let error):
                CategoryRenamePreviewRow(
                    title: "New name",
                    value: trimmedDraftName
                )
                Text(error.renameErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
}

private extension CategoryRenamePreviewSection {
    @ViewBuilder
    func previewDetails(
        for preview: TagRenamePreview
    ) -> some View {
        CategoryRenamePreviewRow(
            title: "New name",
            value: preview.normalizedTargetName ?? trimmedDraftName
        )
        Text("Affected items: \(preview.affectedItemCount)")
            .foregroundStyle(.secondary)

        previewStatus(
            for: preview
        )
    }

    @ViewBuilder
    func previewStatus(
        for preview: TagRenamePreview
    ) -> some View {
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
