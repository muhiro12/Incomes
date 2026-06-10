import SwiftUI

struct SettingsTagMaintenanceSection: View {
    let hasDuplicateTags: Bool
    let hasOrphanTags: Bool
    let indicatorSize: CGFloat
    let openDuplicateTags: () -> Void
    let openOrphanTags: () -> Void

    var body: some View {
        if hasDuplicateTags || hasOrphanTags {
            Section {
                if hasDuplicateTags {
                    Button("Resolve duplicate tags", action: openDuplicateTags)
                }
                if hasOrphanTags {
                    Button("Review orphan tags", action: openOrphanTags)
                }
            } header: {
                HStack {
                    Text("Manage tags")
                    Circle()
                        .frame(width: indicatorSize)
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}
