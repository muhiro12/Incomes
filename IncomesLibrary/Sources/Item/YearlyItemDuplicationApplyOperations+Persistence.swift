import Foundation
import SwiftData

public extension YearlyItemDuplicationApplyOperations {
    /// Saves a complete plan and exposes permanent created IDs only after success.
    /// Pending unrelated edits are refused; failed mutations and saves roll back.
    static func applyAndSaveWithOutcome(
        plan: YearlyItemDuplicationPlan,
        context: ModelContext
    ) throws -> MutationResult<YearlyItemDuplicationResult> {
        try ItemMutationSupport.performAndSaveCreatedItems(context: context) {
            try applyWithOutcome(plan: plan, context: context)
        }
    }

    /// Applies and saves only the selected group without committing unrelated edits.
    static func applyAndSaveWithOutcome(
        groupID: UUID,
        in plan: YearlyItemDuplicationPlan,
        context: ModelContext
    ) throws -> MutationResult<YearlyItemDuplicationResult>? {
        let entries = YearlyItemDuplicationPlanOperations.entries(for: groupID, in: plan)
        guard let group = plan.groups.first(where: { $0.id == groupID }), !entries.isEmpty else {
            return nil
        }
        return try applyAndSaveWithOutcome(
            plan: YearlyItemDuplicationSupport.singleGroupPlan(group: group, entries: entries),
            context: context
        )
    }
}
