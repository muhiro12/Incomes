import SwiftData

public extension ItemUpdateOperations {
    /// Updates entries and saves their amounts, tags, and balances before returning.
    ///
    /// Requires a clean calling context. Mutation and save run without suspension;
    /// failures roll back this operation and preserve the original autosave setting.
    /// Callers must wait for success before running follow-ups or dismissing a form.
    static func updateAndSaveWithOutcome(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> MutationOutcome {
        try ItemMutationSupport.performAndSave(context: context) {
            try updateWithOutcome(context: context, item: item, input: input, scope: scope)
        }
    }

    /// Revalidates a reviewed projection and saves its changes in a clean context.
    ///
    /// Failure and follow-up behavior matches the scope-based overload.
    static func updateAndSaveWithOutcome(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        review: ItemBalanceProjectionReview
    ) throws -> MutationOutcome {
        try ItemMutationSupport.performAndSave(context: context) {
            try updateWithOutcome(context: context, item: item, input: input, review: review)
        }
    }
}
