import SwiftData
import SwiftUI

struct IncomesLargeAmountSampleData: PreviewModifier {
    typealias Context = IncomesPlatformEnvironment

    static func makeSharedContext() throws -> Context {
        try IncomesSampleData.makePreviewContext { previewContext in
            try SampleDataOperations.seed(
                context: previewContext,
                profile: .largeAmounts,
                ifEmptyOnly: true
            )
            try ItemBalanceOperations.recalculate(context: previewContext, date: .distantPast)
        }
    }

    func body(content: Content, context: Context) -> some View {
        content
            .incomesPreviewPlatformEnvironment(context)
    }
}
