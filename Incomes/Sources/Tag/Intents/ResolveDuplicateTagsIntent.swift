import AppIntents
import SwiftData
import SwiftUtilities

struct ResolveDuplicateTagsIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, tags: [TagEntity])
    typealias Output = Void

    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Resolve Duplicate Tags", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let (container, entities) = input
        let context = container.mainContext
        let models: [Tag] = try entities.compactMap { entity in
            let id = try PersistentIdentifier(base64Encoded: entity.id)
            return try context.fetchFirst(.tags(.idIs(id)))
        }
        for model in models {
            let duplicates = try context.fetch(.tags(.isSameWith(model)))
            try MergeDuplicateTagsIntent.perform(
                (
                    container: container,
                    tags: duplicates.compactMap(TagEntity.init)
                )
            )
        }
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform((container: modelContainer, tags: tags))
        return .result()
    }
}
