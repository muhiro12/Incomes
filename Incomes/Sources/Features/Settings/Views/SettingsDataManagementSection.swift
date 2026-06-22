import SwiftUI

struct SettingsDataManagementSection: View {
    let duplicateYearItems: () -> Void
    let deleteAllItems: () -> Void

    var body: some View {
        Section {
            duplicateYearItemsButton
            Button(role: .destructive, action: deleteAllItems) {
                Text("Delete all")
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
