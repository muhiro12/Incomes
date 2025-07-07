import Foundation
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
        try DeleteTagIntent.perform((context: context, tag: .init(tag)!))
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test func performNotFound() throws {
        let entity: TagEntity = .init(
            id: UUID().uuidString,
            name: "missing",
            typeID: TagType.content.rawValue
        )
        #expect(throws: Error.self) {
            try DeleteTagIntent.perform((context: context, tag: entity))
        }
    }
}
