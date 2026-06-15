import SwiftUI

struct CategoryRenameForm: View {
    @Binding var draftName: String

    let currentName: String
    let trimmedDraftName: String
    let previewResult: Result<TagRenamePreview, TagRenameError>
    let cancel: () -> Void
    let save: (Result<TagRenamePreview, TagRenameError>) -> Void

    var body: some View {
        Form {
            CategoryRenameNameSection(draftName: $draftName)
            CategoryRenamePreviewSection(
                currentName: currentName,
                trimmedDraftName: trimmedDraftName,
                previewResult: previewResult
            )
        }
        .formStyle(.grouped)
        .navigationTitle("Rename")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CategoryRenameToolbarContent(
                canSave: canSave,
                cancel: cancel,
                save: savePreview
            )
        }
    }
}

private extension CategoryRenameForm {
    var canSave: Bool {
        switch previewResult {
        case .success(let preview):
            return preview.canApply
        case .failure:
            return false
        }
    }

    func savePreview() {
        save(previewResult)
    }
}
