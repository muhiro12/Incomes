import SwiftUI

struct YearlyDuplicationPreviewSection: View {
    let plan: YearlyItemDuplicationPlan

    var body: some View {
        Section("Preview") {
            Text("Groups: \(plan.groups.count)")
            Text("Items: \(plan.entries.count)")
            if plan.skippedDuplicateCount > .zero {
                Text("Skipped duplicates: \(plan.skippedDuplicateCount)")
                    .foregroundStyle(.secondary)
            }
            if plan.groups.isNotEmpty {
                Text("Select a proposal to edit or create it directly.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
