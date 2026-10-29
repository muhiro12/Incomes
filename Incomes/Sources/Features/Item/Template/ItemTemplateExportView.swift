import MHPlatform
import SwiftUI

struct ItemTemplateExportView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(Item.self)
    private var item

    // The descriptor shorthand fixes .standard and bypasses scene-injected defaults.
    @AppStorage(MHPreferenceDescriptors().currencyCode.storageKey)
    private var currencyCode = ""

    @State private var text = ""
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                Text("Includes date, content, income, outgo, category, priority, and currency.")
                Text("Ledger, balances, repetition, and attachments are omitted.")
                Text("Importing this template prepares a new item. It does not update this item.")
            }
            if let errorMessage {
                Section {
                    Text(errorMessage)
                }
            } else if !text.isEmpty {
                Section {
                    CopyTextContextMenuButton("Copy Template", text: text)
                    ShareLink(item: text) {
                        Label("Share Template", systemImage: "square.and.arrow.up")
                    }
                }
                Section("Template") {
                    Text(verbatim: text)
                        .font(.body.monospaced())
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle("Export Template")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", systemImage: "checkmark") {
                    dismiss()
                }
            }
        }
        .task(id: currencyCode) {
            do {
                text = try ItemTemplateOperations.text(
                    for: item,
                    currencyCode: currencyCode
                )
                errorMessage = nil
            } catch {
                text = ""
                errorMessage = ErrorMessageOperations.message(from: error)
            }
        }
    }
}
