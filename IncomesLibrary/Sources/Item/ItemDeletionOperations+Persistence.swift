import SwiftData

public extension ItemDeletionOperations {
    /// Deletes one entry and saves the remaining balances before returning.
    ///
    /// Requires a clean calling context. Mutation and save run without suspension;
    /// failures roll back this operation and preserve the original autosave setting.
    /// Follow-ups must wait for a successful return.
    static func deleteAndSaveWithOutcome(
        context: ModelContext,
        item: Item
    ) throws -> MutationOutcome {
        try deleteAndSaveWithOutcome(context: context, items: [item])
    }

    /// Deletes a batch and saves its tag cleanup and balances in one clean context.
    ///
    /// Pending unrelated edits are neither saved nor rolled back.
    static func deleteAndSaveWithOutcome(
        context: ModelContext,
        items: [Item]
    ) throws -> MutationOutcome {
        try ItemMutationSupport.performAndSave(context: context) {
            try deleteWithOutcome(context: context, items: items)
        }
    }
}
