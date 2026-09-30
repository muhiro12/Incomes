import SwiftData

public extension ItemImportOperations {
    /// Applies and saves a reviewed import in an isolated context.
    ///
    /// Pending changes in the review context refuse the import and remain
    /// untouched. Validation and save failures roll back only this operation's
    /// context. Follow-ups must run after this method returns successfully.
    static func applyAndSaveWithOutcome(
        contents: IncomesFileContents,
        reviewed difference: ItemImportDifference,
        policy: ItemImportPolicy,
        context reviewContext: ModelContext
    ) throws -> MutationResult<ItemImportResult> {
        guard !reviewContext.hasChanges else {
            throw ItemImportError.storeChangedSinceReview
        }
        let context = ModelContext(reviewContext.container)
        context.autosaveEnabled = false
        do {
            let mutation = try applyWithOutcome(
                contents: contents,
                reviewed: difference,
                policy: policy,
                context: context
            )
            let createdItems = context.insertedModelsArray.compactMap { model in
                model as? Item
            }
            try context.save()
            return .init(
                value: mutation.value,
                outcome: .init(
                    changedIDs: .init(
                        created: Set(createdItems.map(\.persistentModelID)),
                        updated: mutation.outcome.changedIDs.updated,
                        deleted: mutation.outcome.changedIDs.deleted
                    ),
                    affectedDateRange: mutation.outcome.affectedDateRange,
                    followUpHints: mutation.outcome.followUpHints
                )
            )
        } catch {
            context.rollback()
            throw error
        }
    }
}
