import SwiftUI

struct ItemInputAssistanceView: View {
    @Environment(\.dismiss)
    private var dismiss

    let allowsTemplates: Bool

    var body: some View {
        Form {
            if #available(iOS 26.0, *) {
                Section {
                    NavigationLink {
                        ItemFormInputAssistView { dismiss() }
                    } label: {
                        Label("Extract from Text", systemImage: "wand.and.stars")
                    }
                } footer: {
                    Text("Extract item details from pasted text or a photo using Apple Intelligence.")
                }
            }
            if allowsTemplates {
                Section {
                    NavigationLink {
                        ItemTemplateInputView { dismiss() }
                    } label: {
                        Label("Read Template", systemImage: "doc.text")
                    }
                } footer: {
                    Text(
                        "Read explicit template values without AI. Fill the template yourself or with an external tool."
                    )
                }
            }
        }
        .navigationTitle("Input Assistance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
        }
    }
}
