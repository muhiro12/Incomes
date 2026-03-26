import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ModelContainerInitializationTests {
    @Test
    func initWithInvalidURLThrows() throws {
        let invalidParentURL = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString)
        let url = invalidParentURL.appending(path: "store.sqlite")

        try Data().write(to: invalidParentURL)
        defer {
            try? FileManager.default.removeItem(at: invalidParentURL)
        }

        #expect(throws: Error.self) {
            try ModelContainer(
                for: Item.self,
                configurations: .init(url: url)
            )
        }
    }
}
