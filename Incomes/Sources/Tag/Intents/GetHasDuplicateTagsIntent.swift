import AppIntents
import SwiftData

@MainActor
struct GetHasDuplicateTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Has Duplicate Tags", table: "AppIntents")

    func perform() throws -> some ReturnsValue<Bool> {
        let result = try TagService.hasDuplicates(context: modelContainer.mainContext)
        return .result(value: result)
    }
}
