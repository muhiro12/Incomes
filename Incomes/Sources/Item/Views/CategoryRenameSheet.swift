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
            renameForm(
                for: previewResult
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

    func renameForm(
        for previewResult: Result<TagRenamePreview, TagRenameError>
    ) -> some View {
        Form {
            Section {
                TextField("Name", text: $draftName)
            } header: {
                Text("Name")
            }

            previewSection(
                for: previewResult
            )
        }
        .formStyle(.grouped)
        .navigationTitle("Rename")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            renameToolbar(
                for: previewResult
            )
        }
    }

    @ToolbarContentBuilder
    func renameToolbar(
        for previewResult: Result<TagRenamePreview, TagRenameError>
    ) -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                save(
                    using: previewResult
                )
            }
            .disabled(
                !canSave(
                    for: previewResult
                )
            )
        }
    }

    func canSave(
        for previewResult: Result<TagRenamePreview, TagRenameError>
    ) -> Bool {
        switch previewResult {
        case .success(let preview):
            return preview.canApply
        case .failure:
            return false
        }
    }

    @ViewBuilder
    func previewSection(
        for previewResult: Result<TagRenamePreview, TagRenameError>
    ) -> some View {
        Section("Preview") {
            previewSectionContent(
                for: previewResult
            )
        }
    }

    @ViewBuilder
    func previewSectionContent(
        for previewResult: Result<TagRenamePreview, TagRenameError>
    ) -> some View {
        previewRow(
            title: "Current name",
            value: tag.displayName
        )

        switch previewResult {
        case .success(let preview):
            previewDetails(
                for: preview
            )
        case .failure(let error):
            previewRow(
                title: "New name",
                value: trimmedDraftName
            )
            Text(error.renameErrorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    func previewDetails(
        for preview: TagRenamePreview
    ) -> some View {
        previewRow(
            title: "New name",
            value: preview.normalizedTargetName ?? trimmedDraftName
        )
        Text(
            String(
                localized: "Affected items: \(preview.affectedItemCount)"
            )
        )
        .foregroundStyle(.secondary)

        if let statusMessage = previewStatusMessage(
            for: preview
        ) {
            Text(statusMessage)
                .font(.footnote)
                .foregroundStyle(
                    previewStatusColor(
                        for: preview
                    )
                )
        }
    }

    func previewRow(
        title: LocalizedStringKey,
        value: String
    ) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    func previewStatusMessage(
        for preview: TagRenamePreview
    ) -> String? {
        if let validationError = preview.validationError {
            return validationError.renameErrorMessage
        }
        if preview.isUnchanged {
            return String(localized: "This name is unchanged.")
        }

        return nil
    }

    func previewStatusColor(
        for preview: TagRenamePreview
    ) -> Color {
        if preview.validationError != nil {
            return .red
        }

        return .secondary
    }

    func save(
        using previewResult: Result<TagRenamePreview, TagRenameError>
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

private extension TagRenameError {
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
