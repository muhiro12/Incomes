import MHPlatform
import SwiftUI

struct ItemContentShareView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(Item.self)
    private var item
    @Environment(\.locale)
    private var locale

    // The descriptor shorthand fixes .standard and bypasses scene-injected defaults.
    @AppStorage(MHPreferenceDescriptors().currencyCode.storageKey)
    private var currencyCode = ""

    var body: some View {
        let text = ItemContentOperations.text(for: item, currencyCode: currencyCode, locale: locale)

        Form {
            Section {
                CopyTextContextMenuButton("Copy Content", text: text)
                ShareLink(item: text) {
                    Label("Share Content", systemImage: "square.and.arrow.up")
                }
            }
            Section {
                Text(verbatim: text)
                    .textSelection(.enabled)
            } footer: {
                Text("Ledger, balances, repetition, and attachments are omitted.")
            }
        }
        .navigationTitle("Item Content")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", systemImage: "checkmark") {
                    dismiss()
                }
            }
        }
    }
}
