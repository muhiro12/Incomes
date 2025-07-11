import AppIntents
import SwiftData
import SwiftUtilities

struct FindDuplicateTagsIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, tags: [TagEntity])
    typealias Output = [TagEntity]

    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Find Duplicate Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let (context, entities) = input
        let models: [Tag] = try entities.compactMap { entity in
            let id = try PersistentIdentifier(base64Encoded: entity.id)
            return try context.fetchFirst(
                .tags(.idIs(id))
            )
        }
        let duplicates = Dictionary(grouping: models) { tag in
            tag.typeID + tag.name
        }
        .compactMap { _, values -> Tag? in
            guard values.count > 1 else {
                return nil
            }
            return values.first
        }
        return duplicates.compactMap(TagEntity.init)
    }

    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let result = try Self.perform((context: modelContainer.mainContext, tags: tags))
        return .result(value: result)
    }
}
