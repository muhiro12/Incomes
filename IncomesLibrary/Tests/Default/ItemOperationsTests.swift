import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemOperationsTests {
    let context: ModelContext

    init() {
        context = testContext
    }
}
