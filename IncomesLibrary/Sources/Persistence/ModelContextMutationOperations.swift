import SwiftData

/// Establishes an explicit save and rollback boundary for domain mutations.
enum ModelContextMutationOperations {
    /// Preserves earlier pending edits before starting a rollback-capable mutation.
    static func run<Value>(
        context: ModelContext,
        operation: () throws -> Value
    ) throws -> Value {
        try run(
            context: context,
            operation: operation
        ) { value in
            value
        }
    }

    /// Builds the returned value only after temporary model identifiers become persistent.
    static func run<MutationValue, Value>(
        context: ModelContext,
        operation: () throws -> MutationValue,
        afterSave: (MutationValue) -> Value
    ) throws -> Value {
        if context.hasChanges {
            try context.save()
        }

        do {
            let mutationValue = try operation()
            try context.save()
            return afterSave(mutationValue)
        } catch {
            context.rollback()
            throw error
        }
    }
}
