import SwiftUI

struct LedgerSelectionMenu: View {
    let ledgers: [LedgerRecord]
    @Binding var selectedIdentifier: String
    let manage: () -> Void

    var selectedName: String {
        guard let ledger = ledgers.first(where: { $0.id.rawValue == selectedIdentifier }) else {
            return String(localized: "Unavailable Ledger")
        }
        return selectionTitle(ledger)
    }

    var body: some View {
        Menu {
            Picker("Ledger", selection: $selectedIdentifier) {
                ForEach(ledgers) { ledger in
                    Text(selectionTitle(ledger)).tag(ledger.id.rawValue)
                }
            }
            Button("Manage Ledgers", systemImage: "slider.horizontal.3", action: manage)
        } label: {
            Label(
                selectedName,
                systemImage: "books.vertical"
            )
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .truncationMode(.middle)
        }
        .accessibilityLabel(Text(verbatim: String(localized: "Switch Ledger") + ": " + selectedName))
    }

    private func selectionTitle(_ ledger: LedgerRecord) -> String {
        LedgerSelectionTitle.title(
            identifier: ledger.id,
            name: ledger.name,
            names: Dictionary(uniqueKeysWithValues: ledgers.map { ($0.id, $0.name) })
        )
    }
}
