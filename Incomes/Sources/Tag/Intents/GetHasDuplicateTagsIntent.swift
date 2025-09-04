import AppIntents
import SwiftData

struct GetHasDuplicateTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Has Duplicate Tags", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<Bool> {
        let result = try TagService.hasDuplicates(context: modelContainer.mainContext)
        return .result(value: result)
    }
}
