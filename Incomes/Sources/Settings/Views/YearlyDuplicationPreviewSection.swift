import SwiftUI

struct YearlyDuplicationPreviewSection: View {
    let plan: YearlyItemDuplicationPlan

    var body: some View {
        Section("Preview") {
            Text(String(localized: "Groups: \(plan.groups.count)"))
            Text(String(localized: "Items: \(plan.entries.count)"))
            if plan.skippedDuplicateCount > .zero {
                Text(String(localized: "Skipped duplicates: \(plan.skippedDuplicateCount)"))
                    .foregroundStyle(.secondary)
            }
            if plan.groups.isNotEmpty {
                Text(String(localized: "Select a proposal to edit or create it directly."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
