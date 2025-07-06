import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteAllTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Void

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete All Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let tags = try input.fetch(FetchDescriptor<Tag>())
        tags.forEach { tag in
            tag.delete()
        }
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform(modelContainer.mainContext)
        return .result()
    }
}
