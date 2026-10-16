import SwiftUI

struct LedgerSelectionMenu: View {
    let accounts: [LedgerRecord]
    @Binding var selectedIdentifier: String
    let manage: () -> Void

    var selectedName: String {
        accounts.first { $0.id.rawValue == selectedIdentifier }?.name
            ?? String(localized: "Unavailable Account")
    }

    var body: some View {
        Menu {
            Picker("Account", selection: $selectedIdentifier) {
                ForEach(accounts) { account in
                    Text(selectionTitle(account)).tag(account.id.rawValue)
                }
            }
            Button("Manage Accounts", systemImage: "slider.horizontal.3", action: manage)
        } label: {
            Label(
                selectedName,
                systemImage: "books.vertical"
            )
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
        }
        .accessibilityLabel(Text(verbatim: String(localized: "Switch Account") + ": " + selectedName))
    }

    private func selectionTitle(_ account: LedgerRecord) -> String {
        LedgerSelectionTitle.title(
            identifier: account.id,
            name: account.name,
            names: Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0.name) })
        )
    }
}
