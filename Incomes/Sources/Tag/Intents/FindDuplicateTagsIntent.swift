import AppIntents
import SwiftData
import SwiftUtilities

struct FindDuplicateTagsIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, tags: [TagEntity])
    typealias Output = [TagEntity]

    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Find Duplicate Tags", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let (container, entities) = input
        let models: [Tag] = try entities.compactMap { entity in
            let id = try PersistentIdentifier(base64Encoded: entity.id)
            return try container.mainContext.fetchFirst(
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

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let result = try Self.perform((container: modelContainer, tags: tags))
        return .result(value: result)
    }
}
