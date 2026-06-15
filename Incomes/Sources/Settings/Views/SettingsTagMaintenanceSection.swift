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
                        systemImage: "tag",
                        accessibilityHint: "Opens duplicate tag cleanup.",
                        action: openDuplicateTags
                    )
                }
                if hasOrphanTags {
                    SettingsNavigationRowButton(
                        title: "Review orphan tags",
                        systemImage: "tag.slash",
                        accessibilityHint: "Opens orphan tag cleanup.",
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
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Manage tags, attention needed"))
                .accessibilityAddTraits(.isHeader)
            }
        }
    }
}
