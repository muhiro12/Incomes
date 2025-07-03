@testable import Incomes
import SwiftData
import Testing

@MainActor
struct FindDuplicateTagsIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        let tag1 = try Tag.createIgnoringDuplicates(container: container, name: "A", type: .year)
        let tag2 = try Tag.createIgnoringDuplicates(container: container, name: "A", type: .year)
        let tag3 = try Tag.createIgnoringDuplicates(container: container, name: "B", type: .yearMonth)
        let tag4 = try Tag.createIgnoringDuplicates(container: container, name: "B", type: .yearMonth)

        let result = try FindDuplicateTagsIntent.perform(
            (
                container: container,
                tags: [tag1, tag2, tag3, tag4].compactMap(TagEntity.init)
            )
        )

        #expect(result.count == 2)
        #expect(result.contains {
            (try? PersistentIdentifier(base64Encoded: $0.id)) == tag1.id
        })
        #expect(result.contains {
            (try? PersistentIdentifier(base64Encoded: $0.id)) == tag3.id
        })
    }
}
