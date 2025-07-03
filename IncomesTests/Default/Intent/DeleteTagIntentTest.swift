@testable import Incomes
import SwiftData
import Testing

@MainActor
struct DeleteTagIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        let tag = try Tag.create(context: container.mainContext, name: "name", type: .year)
        #expect(try container.mainContext.fetchCount(.tags(.all)) == 1)
        try DeleteTagIntent.perform((container: container, tag: .init(tag)!))
        #expect(try container.mainContext.fetchCount(.tags(.all)) == 0)
    }
}
