import SwiftData

public extension ItemCreationOperations {
    /// Creates and saves monthly repeating items before returning mutation metadata.
    ///
    /// The calling context must have no pending changes. Creation, balance updates,
    /// and save run without suspension, preserving live model references. Failures
    /// roll back only the changes made by this operation. Follow-ups must wait for
    /// a successful return, which contains permanent created identifiers.
    static func createAndSaveWithOutcome(
        context: ModelContext,
        input: ItemFormInput,
        repeatCount: Int
    ) throws -> MutationResult<Item> {
        try performAndSaveCreation(context: context) {
            try createWithOutcome(
                context: context,
                input: input,
                repeatCount: repeatCount
            )
        }
    }

    /// Creates and saves items for selected months in a clean calling context.
    ///
    /// Failure and follow-up behavior matches the repeat-count overload.
    static func createAndSaveWithOutcome(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> MutationResult<Item> {
        try performAndSaveCreation(context: context) {
            try createWithOutcome(
                context: context,
                input: input,
                repeatMonthSelections: repeatMonthSelections
            )
        }
    }

    /// Revalidates a reviewed projection, creates its items, and saves synchronously.
    ///
    /// Pending changes refuse the operation without saving or rolling them back.
    static func createAndSaveWithOutcome(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>,
        review: ItemBalanceProjectionReview
    ) throws -> MutationResult<Item> {
        try performAndSaveCreation(context: context) {
            try createWithOutcome(
                context: context,
                input: input,
                repeatMonthSelections: repeatMonthSelections,
                review: review
            )
        }
    }
}

private extension ItemCreationOperations {
    static func performAndSaveCreation(
        context: ModelContext,
        operation: () throws -> MutationResult<Item>
    ) throws -> MutationResult<Item> {
        guard !context.hasChanges else {
            throw ItemCreationError.pendingChanges
        }
        let autosaveEnabled = context.autosaveEnabled
        context.autosaveEnabled = false
        defer {
            context.autosaveEnabled = autosaveEnabled
        }
        do {
            let mutation = try operation()
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
