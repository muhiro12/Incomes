@testable import Incomes
import SwiftData
import Testing

@MainActor
struct DeleteAllTagsIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try Tag.create(context: context, name: "A", type: .content)
        _ = try Tag.create(context: context, name: "B", type: .content)
        #expect(try context.fetchCount(.tags(.all)) == 2)
        try DeleteAllTagsIntent.perform(context)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test func performWhenEmpty() throws {
        #expect(try context.fetchCount(.tags(.all)) == 0)
        try DeleteAllTagsIntent.perform(context)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }
}
