@testable import Incomes
import SwiftData
import Testing

@MainActor
struct DeleteTagIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let tag = try Tag.create(context: context, name: "name", type: .year)
        #expect(try context.fetchCount(.tags(.all)) == 1)
        try DeleteTagIntent.perform((container: context.container, tag: .init(tag)!))
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }
}
