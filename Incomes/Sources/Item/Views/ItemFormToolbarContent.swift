import SwiftUI

struct ItemFormToolbarContent: ToolbarContent {
    let mode: ItemFormView.Mode
    let isValid: Bool
    let focusedField: ItemFormFocusedField?
    @Binding var content: String
    @Binding var category: String
    let cancel: () -> Void
    let submit: () -> Void
    let presentAssist: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: cancel) {
                Text("Cancel")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button(action: submit) {
                if mode == .create {
                    Text("Create")
                } else {
                    Text("Save")
                }
            }
            .bold()
            .disabled(!isValid)
        }
        if focusedField == .content {
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $content, type: .content)
            }
        }
        if focusedField == .category {
            ToolbarItem(placement: .keyboard) {
                SuggestionButtonGroup(input: $category, type: .category)
            }
        }
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .bottomBar) {
                Button(action: presentAssist) {
                    Label("Text Capture", systemImage: "wand.and.stars")
                }
                .incomesSecondaryControlStyle()
            }
        }
    }
}
