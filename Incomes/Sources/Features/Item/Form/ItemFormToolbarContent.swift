import SwiftUI

struct ItemFormToolbarContent: ToolbarContent {
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    let mode: ItemFormView.Mode
    let isValid: Bool
    let primaryActionAccessibilityHint: LocalizedStringKey
    let focusedField: ItemFormFocusedField?
    @Binding var content: String
    @Binding var category: String
    let cancel: () -> Void
    let submit: () -> Void
    let presentAssist: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark", action: cancel)
        }
        ToolbarItem(placement: .primaryAction) {
            Button(action: submit) {
                if mode == .create {
                    Label("Create", systemImage: "square.and.pencil")
                } else {
                    Label("Save", systemImage: "checkmark")
                }
            }
            .bold()
            .disabled(!isValid)
            .accessibilityHint(Text(primaryActionAccessibilityHint))
        }
        if focusedField == .content {
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $content, type: .content, ledgerIdentifier: ledgerIdentifier)
            }
        }
        if focusedField == .category {
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $category, type: .category, ledgerIdentifier: ledgerIdentifier)
            }
        }
        if #available(iOS 26.0, *) {
            SpacerToolbarItem(placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button(action: presentAssist) {
                    Label("Text Capture", systemImage: "wand.and.stars")
                }
                .accessibilityHint(Text("Opens text capture to extract item details."))
            }
        }
    }
}
