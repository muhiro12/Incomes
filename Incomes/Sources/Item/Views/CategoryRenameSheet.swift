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
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draftName)
                } header: {
                    Text("Name")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Rename")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
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
            Text(errorMessage ?? .empty)
        }
    }
}

private extension CategoryRenameSheet {
    var canSave: Bool {
        normalizedDraftName != nil
    }

    var normalizedDraftName: String? {
        let trimmedName = draftName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard trimmedName.isNotEmpty else {
            return nil
        }

        let normalizedTargetName = CategoryNameSupport.normalizedStoredName(
            forUserInput: trimmedName
        )
        guard CategoryNameSupport.isOthersLike(normalizedTargetName) == false else {
            return nil
        }

        return normalizedTargetName
    }

    func save() {
        guard let normalizedDraftName else {
            errorMessage = String(
                localized: "Enter a valid category name."
            )
            return
        }

        do {
            try TagService.renameCategory(
                context: context,
                tag: tag,
                to: normalizedDraftName
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
