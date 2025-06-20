import AppIntents
import SwiftData
import SwiftUtilities

struct MergeDuplicateTagsIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Merge Duplicate Tags", table: "AppIntents")

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
        guard let parent = models.first else {
            return
        }
        let children = models.filter {
            $0.id != parent.id
        }
        for item in children.flatMap({ $0.items ?? [] }) {
            var tags = item.tags ?? []
            tags.append(parent)
            item.modify(tags: tags)
        }
        try children.compactMap(TagEntity.init).forEach { child in
            try DeleteTagIntent.perform((context: context, tag: child))
        }
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, tags: tags))
        return .result()
    }
}
