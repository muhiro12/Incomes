import AppIntents
import SwiftData
import SwiftUtilities

struct ResolveDuplicateTagsIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Resolve Duplicate Tags", table: "AppIntents")

    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, tags: [TagEntity])
    typealias Output = Void

    static func perform(_ input: Input) throws -> Output {
        let (context, entities) = input
        let models: [Tag] = try entities.compactMap { entity in
            let id = try PersistentIdentifier(base64Encoded: entity.id)
            return try context.fetchFirst(.tags(.idIs(id)))
        }
        for model in models {
            let duplicates = try context.fetch(.tags(.isSameWith(model)))
            try MergeDuplicateTagsIntent.perform(
                (
                    context: context,
                    tags: duplicates.compactMap(TagEntity.init)
                )
            )
        }
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, tags: tags))
        return .result()
    }
}
