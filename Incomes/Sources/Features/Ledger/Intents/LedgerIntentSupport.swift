import SwiftData

@MainActor
enum LedgerIntentSupport {
    static func entities(context: ModelContext) throws -> [LedgerEntity] {
        let ledgers = try LedgerOperations.ledgers(context: context).filter(\.isAvailable)
        let names = Dictionary(uniqueKeysWithValues: ledgers.map { ($0.id, $0.name) })
        return ledgers.map { LedgerEntity($0, names: names) }
    }

    /// Omitted parameters preserve the scope of already-saved Shortcuts.
    static func identifier(for ledger: LedgerEntity?, context: ModelContext) throws -> LedgerIdentifier {
        try IncomesIntentError.perform {
            let identifier = ledger?.identifier ?? .default
            try LedgerOperations.requireAvailable(identifier, context: context)
            return identifier
        }
    }

    static func checkMutationAllowed() async throws {
        do {
            try await IncomesMutationWorkflow.checkUpdateRequirement()
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw IncomesIntentError(error)
        }
    }
}
