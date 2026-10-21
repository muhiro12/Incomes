import AppIntents
import SwiftData

struct GetUnassignedItemsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Unassigned Items", table: "AppIntents")
    static let isDiscoverable = false

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try IncomesIntentError.perform {
            try ItemQueryOperations.items(context: modelContainer.mainContext, ledgerIdentifier: .unassigned)
        }
        return .result(value: try ItemEntity.make(from: items))
    }
}
