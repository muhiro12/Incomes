import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct SaveFailureFixtureTests {
    @Test
    func the_store_rejects_an_actual_save_and_can_save_again_after_recovery() throws {
        try SaveFailureFixture.withStore { fixture in
            _ = Tag.createIgnoringDuplicates(context: fixture.context, name: "Retry", type: .category)
            try fixture.context.save()
            let context = try fixture.readOnlyContext()
            let tag = try #require(try context.fetch(.tags(.all)).first)
            fixture.observeSaves(in: context)
            #expect(throws: (any Error).self) {
                try MutationPersistenceSupport.commit(context: context) {
                    tag.rename(storedName: "Changed")
                }
            }
            #expect(fixture.saveAttempts == 1)
            #expect(!context.hasChanges)
            // iOS 18 does not restore the live graph after forcing mutations into
            // a read-only context. Public operations refuse that unsupported path.
            if #available(iOS 27, *) {
                #expect(tag.name == "Retry")
            }
            #expect(try fixture.reopenedContext().fetch(.tags(.all)).first?.name == "Retry")
            let retry = try fixture.reopenedContext()
            let savedTag = try #require(try retry.fetch(.tags(.all)).first)
            _ = try TagRenameOperations.renameCategoryAndSave(context: retry, tag: savedTag, to: "Changed")
            #expect(try fixture.reopenedContext().fetch(.tags(.all)).first?.name == "Changed")
        }
    }
}
