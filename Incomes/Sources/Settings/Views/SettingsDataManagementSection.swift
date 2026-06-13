import SwiftUI
import TipKit

struct SettingsDataManagementSection: View {
    let showsYearlyDuplicationTip: Bool
    let duplicateYearItems: () -> Void
    let deleteAllItems: () -> Void

    private let yearlyDuplicationTip = YearlyDuplicationTip()

    var body: some View {
        Section {
            if showsYearlyDuplicationTip {
                duplicateYearItemsButton
                    .popoverTip(yearlyDuplicationTip, arrowEdge: .top)
            } else {
                duplicateYearItemsButton
            }

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
            action: duplicateYearItems
        )
    }
}
