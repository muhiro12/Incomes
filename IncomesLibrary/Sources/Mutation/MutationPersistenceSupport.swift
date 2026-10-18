import SwiftData

/// Commits an operation after its caller has established clean-context ownership.
enum MutationPersistenceSupport {
    static func commit<Value>(context: ModelContext, operation: () throws -> Value) throws -> Value {
        let autosaveEnabled = context.autosaveEnabled
        context.autosaveEnabled = false
        defer {
            context.autosaveEnabled = autosaveEnabled
        }
        do {
            let value = try operation()
            try context.save()
            return value
        } catch {
            context.rollback()
            throw error
        }
    }
}
