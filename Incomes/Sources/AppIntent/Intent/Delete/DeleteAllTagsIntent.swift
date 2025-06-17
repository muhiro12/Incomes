import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteAllTagsIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Delete All Tags", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    typealias Input = ModelContext
    typealias Output = Void

    static func perform(_ input: Input) throws -> Output {
        let context = input
        let tags = try context.fetch(FetchDescriptor<Tag>())
        tags.forEach { $0.delete() }
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform(modelContainer.mainContext)
        return .result()
    }
}
