import SwiftData
import SwiftUI

/// Previews with the standard ledger plus duplicate tags of every type in an in-memory store.
struct IncomesDuplicateTagSampleData: PreviewModifier {
    typealias Context = IncomesPlatformEnvironment

    static func makeSharedContext() throws -> Context {
        try IncomesSampleData.makePreviewContext(profile: .duplicateTags)
    }

    func body(content: Content, context: Context) -> some View {
        content
            .incomesPreviewPlatformEnvironment(context)
    }
}
