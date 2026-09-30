import SwiftData
import SwiftUI

/// Previews with amounts whose totals cannot be represented exactly in an in-memory store.
struct IncomesInexactTotalSampleData: PreviewModifier {
    typealias Context = IncomesPlatformEnvironment

    static func makeSharedContext() throws -> Context {
        try IncomesSampleData.makePreviewContext(profile: .inexactTotals)
    }

    func body(content: Content, context: Context) -> some View {
        content
            .incomesPreviewPlatformEnvironment(context)
    }
}
