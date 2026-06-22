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
                CategoryRenamePreviewDetails(
                    trimmedDraftName: trimmedDraftName,
                    preview: preview
                )
            case .failure(let error):
                CategoryRenamePreviewFailureDetails(
                    trimmedDraftName: trimmedDraftName,
                    error: error
                )
            }
        }
    }
}
