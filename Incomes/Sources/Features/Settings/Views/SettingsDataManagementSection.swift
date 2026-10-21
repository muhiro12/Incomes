import SwiftUI

struct SettingsDataManagementSection: View {
    let duplicateYearItems: () -> Void

    var body: some View {
        Section {
            duplicateYearItemsButton
            NavigationLink {
                DataExportView()
            } label: {
                Label("Export data", systemImage: "square.and.arrow.up")
            }
            NavigationLink {
                DataImportView()
            } label: {
                Label("Import data", systemImage: "square.and.arrow.down")
            }
        } header: {
            Text("Manage items")
        }
    }
}

private extension SettingsDataManagementSection {
    var duplicateYearItemsButton: some View {
        SettingsNavigationRowButton(
            title: "Duplicate year items",
            systemImage: "calendar.badge.plus",
            accessibilityHint: "Opens yearly duplication proposals.",
            action: duplicateYearItems
        )
    }
}
