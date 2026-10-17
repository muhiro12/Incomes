import SwiftUI

/// Identifies the affected book even when names and financial values match.
struct DataImportLedgerLabel: View {
    @Environment(\.importLedgerNames)
    private var names

    let identifier: LedgerIdentifier

    private var title: String {
        let fallback =
            identifier == .default
            ? String(localized: "Default Ledger") : String(localized: "Unavailable Ledger")
        let name = names[identifier] ?? fallback
        return LedgerSelectionTitle.title(identifier: identifier, name: name, names: names)
    }

    var body: some View {
        Text(verbatim: title).font(.caption).foregroundStyle(.secondary).textCase(nil)
    }
}
