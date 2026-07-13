import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ModelContextMutationOperationsTests {
    private enum ExpectedError: Error {
        case failed
    }

    @Test
    func run_savesExistingChangesBeforeRollingBackFailedMutation() throws {
        let context = testContext
        _ = try makeItem(
            context: context,
            content: "Existing"
        )

        #expect(context.hasChanges)
        #expect(throws: ExpectedError.failed) {
            try ModelContextMutationOperations.run(context: context) {
                _ = try makeItem(
                    context: context,
                    content: "Failed"
                )
                throw ExpectedError.failed
            }
        }

        let items = try context.fetch(FetchDescriptor<Item>())
        #expect(items.map(\.content) == ["Existing"])
        #expect(context.hasChanges == false)
    }

    @Test
    func run_savesSuccessfulMutation() throws {
        let context = testContext

        _ = try ModelContextMutationOperations.run(context: context) {
            try makeItem(
                context: context,
                content: "Saved"
            )
        }

        #expect(try context.fetchCount(FetchDescriptor<Item>()) == 1)
        #expect(context.hasChanges == false)
    }

    private func makeItem(
        context: ModelContext,
        content: String
    ) throws -> Item {
        try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: content,
                income: 100,
                outgo: .zero,
                category: "Category",
                priority: .zero
            ),
            repeatID: UUID()
        )
    }
}
