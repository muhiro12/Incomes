import SwiftUI

struct CategoryRenamePreviewFailureDetails: View {
    let trimmedDraftName: String
    let error: TagRenameError

    var body: some View {
        CategoryRenamePreviewRow(
            title: "New name",
            value: trimmedDraftName
        )
        Text(error.renameErrorMessage)
            .font(.footnote)
            .foregroundStyle(.red)
    }
}
