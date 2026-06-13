import SwiftUI

struct SettingsTagMaintenanceSection: View {
    let hasDuplicateTags: Bool
    let hasOrphanTags: Bool
    let openDuplicateTags: () -> Void
    let openOrphanTags: () -> Void

    var body: some View {
        if hasDuplicateTags || hasOrphanTags {
            Section {
                if hasDuplicateTags {
                    SettingsNavigationRowButton(
                        title: "Resolve duplicate tags",
                        action: openDuplicateTags
                    )
                }
                if hasOrphanTags {
                    SettingsNavigationRowButton(
                        title: "Review orphan tags",
                        action: openOrphanTags
                    )
                }
            } header: {
                HStack {
                    Text("Manage tags")
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}
