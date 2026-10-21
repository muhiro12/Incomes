import AppIntents
import SwiftData

struct LedgerEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func entities(for identifiers: [LedgerEntity.ID]) throws -> [LedgerEntity] {
        let selected = Set(identifiers)
        return try entities().filter { selected.contains($0.id) }
    }

    @MainActor
    func entities(matching string: String) throws -> [LedgerEntity] {
        try entities().filter { $0.name.localizedStandardContains(string) }
    }

    @MainActor
    func suggestedEntities() throws -> [LedgerEntity] {
        try entities()
    }

    @MainActor
    private func entities() throws -> [LedgerEntity] {
        try LedgerIntentSupport.entities(context: modelContainer.mainContext)
    }
}
