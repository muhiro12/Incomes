@testable import Incomes
import SwiftData
import Testing

struct ModelContainerInitializationTests {
    @Test
    func initWithInvalidURLThrows() {
        let url: URL = .init(fileURLWithPath: "/root/invalid/dir/store.sqlite")
        #expect(throws: any Error.self) {
            try ModelContainer(
                for: Item.self,
                configurations: .init(url: url)
            )
        }
    }
}
