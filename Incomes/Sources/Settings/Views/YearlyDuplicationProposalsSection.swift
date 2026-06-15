import Foundation
import SwiftUI

struct YearlyDuplicationProposalsSection: View {
    let plan: YearlyItemDuplicationPlan
    let createdGroupIDs: Set<UUID>
    let inlineSpacing: CGFloat
    let verticalPadding: CGFloat
    let summaryText: (YearlyItemDuplicationGroup) -> String
    let edit: (YearlyItemDuplicationGroup) -> Void
    let create: (YearlyItemDuplicationGroup) -> Void

    var body: some View {
        Section("Proposals") {
            if plan.groups.isEmpty {
                YearlyDuplicationNoProposalsView()
            } else {
                ForEach(plan.groups, id: \.id) { group in
                    let entries = YearlyItemDuplicationPlanOperations.entries(
                        for: group.id,
                        in: plan
                    )
                    let isCreated = createdGroupIDs.contains(group.id)
                    YearlyDuplicationProposalRow(
                        group: group,
                        isCreated: isCreated,
                        isActionDisabled: isCreated || entries.isEmpty,
                        inlineSpacing: inlineSpacing,
                        verticalPadding: verticalPadding,
                        summaryText: summaryText(group),
                        edit: {
                            edit(group)
                        },
                        create: {
                            create(group)
                        }
                    )
                }
            }
        }
    }
}
