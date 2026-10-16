import Foundation
import MHPlatform
import SwiftUI

struct YearlyDuplicationProposalsSection: View {
    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn

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
                        isActionDisabled: isCreated || entries.isEmpty || !canEdit(entries: entries),
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

    private func canEdit(entries: [YearlyItemDuplicationEntry]) -> Bool {
        entries.allSatisfy { LedgerAccessOperations.canEdit($0.sourceItem.ledgerIdentifier, isPremium: isSubscribeOn) }
    }
}
