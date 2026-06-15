import Foundation
import SwiftData
import SwiftUI

struct CategoryRenameSheet: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context

    let tag: Tag

    @State private var draftName: String
    @State private var errorMessage: String?

    init(tag: Tag) { // swiftlint:disable:this type_contents_order
        self.tag = tag
        _draftName = .init(
            initialValue: tag.displayName
        )
    }

    var body: some View {
        let previewResult = categoryRenamePreviewResult

        NavigationStack {
            CategoryRenameForm(
                draftName: $draftName,
                currentName: tag.displayName,
                trimmedDraftName: trimmedDraftName,
                previewResult: previewResult,
                cancel: {
                    dismiss()
                },
                save: save
            )
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: {
                    errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

private extension CategoryRenameSheet {
    var categoryRenamePreviewResult: Result<TagRenamePreview, TagRenameError> {
        do {
            return .success(
                try TagRenameOperations.previewCategoryRename(
                    context: context,
                    tag: tag,
                    to: draftName
                )
            )
        } catch let error as TagRenameError {
            return .failure(error)
        } catch {
            return .failure(.unsupportedType)
        }
    }

    var trimmedDraftName: String {
        draftName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    func save(
        _ previewResult: Result<TagRenamePreview, TagRenameError>
    ) {
        do {
            let preview = try previewResult.get()
            guard let normalizedTargetName = preview.normalizedTargetName else {
                errorMessage = String(
                    localized: "Enter a valid category name."
                )
                return
            }
            if let validationError = preview.validationError {
                errorMessage = validationError.renameErrorMessage
                return
            }
            guard preview.isUnchanged == false else {
                errorMessage = String(
                    localized: "This name is unchanged."
                )
                return
            }

            try TagRenameOperations.renameCategory(
                context: context,
                tag: tag,
                to: normalizedTargetName
            )
            dismiss()
        } catch let error as TagRenameError {
            errorMessage = error.renameErrorMessage
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

extension TagRenameError {
    var renameErrorMessage: String {
        switch self {
        case .unsupportedType,
             .uncategorizedSource:
            return String(localized: "This category can't be renamed.")
        case .invalidTarget:
            return String(localized: "Enter a valid category name.")
        case .duplicateTargetName:
            return String(localized: "A category with this name already exists.")
        }
    }
}
