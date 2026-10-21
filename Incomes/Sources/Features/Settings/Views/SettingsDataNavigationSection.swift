import SwiftUI

struct SettingsDataNavigationSection: View {
    let selectedLedgerIdentifier: Binding<String>?
    let duplicateYearItems: () -> Void

    var body: some View {
        Section("Ledgers and Data") {
            if let selectedLedgerIdentifier {
                NavigationLink {
                    LedgerManagementView(selectedIdentifier: selectedLedgerIdentifier)
                } label: {
                    Label("Manage Ledgers", systemImage: "books.vertical")
                }
            }
            NavigationLink {
                List {
                    SettingsDataManagementSection(duplicateYearItems: duplicateYearItems)
                }
                .navigationTitle("Data Management")
                .navigationBarTitleDisplayMode(.inline)
            } label: {
                Label("Data Management", systemImage: "externaldrive")
            }
        }
    }
}
