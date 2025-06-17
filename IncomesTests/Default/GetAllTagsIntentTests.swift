@testable import Incomes
import SwiftData
import Testing

struct GetAllTagsIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try Tag.create(context: context, name: "A", type: .year)
        _ = try Tag.create(context: context, name: "B", type: .content)
        let tags = try GetAllTagsIntent.perform(context)
        #expect(tags.count == 2)
    }
}
