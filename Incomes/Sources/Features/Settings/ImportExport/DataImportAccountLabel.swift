import SwiftUI

/// Identifies the affected book even when names and financial values match.
struct DataImportAccountLabel: View {
    @Environment(\.importAccountNames)
    private var names

    let identifier: LedgerIdentifier

    private var title: String {
        let fallback =
            identifier == .default
            ? String(localized: "Default Account") : String(localized: "Unavailable Account")
        let name = names[identifier] ?? fallback
        return LedgerSelectionTitle.title(identifier: identifier, name: name, names: names)
    }

    var body: some View {
        Text(verbatim: title).font(.caption).foregroundStyle(.secondary).textCase(nil)
    }
}
