@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetAllTagsIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        _ = try Tag.create(container: container, name: "A", type: .year)
        _ = try Tag.create(container: container, name: "B", type: .content)
        let tags = try GetAllTagsIntent.perform(container)
        #expect(tags.count == 2)
    }
}
