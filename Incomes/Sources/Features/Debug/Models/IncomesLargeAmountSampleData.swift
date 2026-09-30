import SwiftData
import SwiftUI

/// Previews with monthly amounts around ±1,000,000 in an in-memory store.
struct IncomesLargeAmountSampleData: PreviewModifier {
    typealias Context = IncomesPlatformEnvironment

    static func makeSharedContext() throws -> Context {
        try IncomesSampleData.makePreviewContext(profile: .largeAmounts)
    }

    func body(content: Content, context: Context) -> some View {
        content
            .incomesPreviewPlatformEnvironment(context)
    }
}
